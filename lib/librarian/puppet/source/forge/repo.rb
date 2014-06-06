require 'json'
require 'open-uri'
require 'librarian/puppet/util'
require 'librarian/puppet/source/repo'

module Librarian
  module Puppet
    module Source
      class Forge
        class Repo < Librarian::Puppet::Source::Repo
          include Librarian::Puppet::Util

          def initialize(source, name)
            super(source, name)
            # API returned data for this module including all versions and dependencies, indexed by module name
            # from http://forge.puppetlabs.com/api/v1/releases.json?module=#{name}
            @api_data = nil
            # API returned data for this module and a specific version, indexed by version
            # from http://forge.puppetlabs.com/api/v1/releases.json?module=#{name}&version=#{version}
            @api_version_data = {}
          end

          def versions
            return @versions if @versions
            @versions = api_data(name).map { |r| r['version'] }.reverse
            if @versions.empty?
              info { "No versions found for module #{name}" }
            else
              debug { "  Module #{name} found versions: #{@versions.join(", ")}" }
            end
            @versions
          end

          def dependencies(version)
            api_version_data(name, version)['dependencies']
          end

          def manifests
            versions.map do |version|
              Manifest.new(source, name, version)
            end
          end

          def install_version!(version, install_path)
            if environment.local? && !vendored?(name, version)
              raise Error, "Could not find a local copy of #{name} at #{version}."
            end

            if environment.vendor?
              vendor_cache(name, version) unless vendored?(name, version)
            end

            cache_version_unpacked! version

            if install_path.exist?
              install_path.rmtree
            end

            unpacked_path = version_unpacked_cache_path(version).join(name.split('/').last)

            unless unpacked_path.exist?
              raise Error, "#{unpacked_path} does not exist, something went wrong. Try removing it manually"
            else
              cp_r(unpacked_path, install_path)
            end

          end

          def cache_version_unpacked!(version)
            path = version_unpacked_cache_path(version)
            return if path.directory?

            # The puppet module command is only available from puppet versions >= 2.7.13
            #
            # Specifying the version in the gemspec would force people to upgrade puppet while it's still usable for git
            # So we do some more clever checking
            #
            # Executing older versions or via puppet-module tool gives an exit status = 0 .
            #
            check_puppet_module_options

            path.mkpath

            target = vendored?(name, version) ? vendored_path(name, version).to_s : name

            # TODO can't pass the default forge url (http://forge.puppetlabs.com) to clients that use the v3 API (https://forgeapi.puppetlabs.com)
            module_repository = source.to_s
            if Forge.client_api_version() > 1 and module_repository =~ %r{^http(s)?://forge\.puppetlabs\.com}
              module_repository = "https://forgeapi.puppetlabs.com"
            end

            command = %W{puppet module install --version #{version} --target-dir}
            command.push(*[path.to_s, "--module_repository", module_repository, "--modulepath", path.to_s, "--module_working_dir", path.to_s, "--ignore-dependencies", target])
            debug { "Executing puppet module install for #{name} #{version}: #{command.join(" ")}" }

            begin
              Librarian::Posix.run!(command)
            rescue Posix::CommandFailure => e
              # Rollback the directory if the puppet module had an error
              begin
                path.unlink
              rescue => u
                debug("Unable to rollback path #{path}: #{u}")
              end
              tar = Dir[File.join(path.to_s, "**/*.tar.gz")]
              msg = ""
              if e.message =~ /Unexpected EOF in archive/ and !tar.empty?
                file = tar.first
                msg = " (looks like an incomplete download of #{file})"
              end
              raise Error, "Error executing puppet module install#{msg}. Check that this command succeeds:\n#{command.join(" ")}\nError:\n#{e.message}"
            end

          end

          def check_puppet_module_options
            min_version    = Gem::Version.create('2.7.13')

            if Librarian::Puppet.puppet_gem_version < min_version
              raise Error, "To get modules from the forge, we use the puppet faces module command. For this you need at least puppet version 2.7.13 and you have #{puppet_version}"
            end
          end

          def vendor_cache(name, version)
            info = api_version_data(name, version)
            url = "#{source}#{info[name].first['file']}"
            path = vendored_path(name, version).to_s
            debug { "Downloading #{url} into #{path}"}
            environment.vendor!
            File.open(path, 'wb') do |f|
              open(url, "rb") do |input|
                f.write(input.read)
              end
            end
          end

        private

          # Issue #223 dependencies may be duplicated
          def clear_duplicated_dependencies(data)
            return nil if data.nil?
            data.each do |m,versions|
              versions.each do |v|
                if v["dependencies"] and !v["dependencies"].empty?
                  dependency_names = v["dependencies"].map {|d| d[0]}
                  duplicated = dependency_names.select{ |e| dependency_names.count(e) > 1 }
                  unless duplicated.empty?
                    duplicated.uniq.each do |module_duplicated|
                      to_remove = []
                      v["dependencies"].each_index{|i| to_remove << i if module_duplicated == v["dependencies"][i][0]}
                      warn { "Module #{m}@#{v["version"]} contains duplicated dependencies for #{module_duplicated}, ignoring all but the first of #{to_remove.map {|i| v["dependencies"][i]}}" }
                      to_remove.slice(1..-1).reverse.each {|i| v["dependencies"].delete_at(i) }
                      v["dependencies"] = v["dependencies"] - to_remove.slice(1..-1)
                    end
                  end
                end
              end
            end
            data
          end

          # get and cache the API data for a specific module with all its versions and dependencies
          def api_data(module_name)
            return @api_data[module_name] if @api_data
            # call API and cache data
            @api_data = clear_duplicated_dependencies(api_call(module_name))
            if @api_data.nil?
              raise Error, "Unable to find module '#{name}' on #{source}"
            end
            @api_data[module_name]
          end

          # get and cache the API data for a specific module and version
          def api_version_data(module_name, version)
            # if we already got all the versions, find in cached data
            return @api_data[module_name].detect{|x| x['version'] == version.to_s} if @api_data
            # otherwise call the api for this version if not cached already
            @api_version_data[version] = clear_duplicated_dependencies(api_call(name, version)) if @api_version_data[version].nil?
            @api_version_data[version]
          end

          def api_call(module_name, version=nil)
            url = source.uri.clone
            url.path += "#{'/' if url.path.empty? or url.path[-1] != '/'}api/v1/releases.json"
            url.query = "module=#{module_name}"
            url.query += "&version=#{version}" unless version.nil?
            debug { "Querying Forge API for module #{name}#{" and version #{version}" unless version.nil?}: #{url}" }

            begin
              data = open(url) {|f| f.read}
              JSON.parse(data)
            rescue OpenURI::HTTPError => e
              case e.io.status[0].to_i
              when 404,410
                nil
              else
                raise e, "Error requesting #{url}: #{e.to_s}"
              end
            end
          end
        end
      end
    end
  end
end

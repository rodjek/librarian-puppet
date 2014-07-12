require 'json'
require 'open-uri'
require 'librarian/puppet/source/forge/repo'

module Librarian
  module Puppet
    module Source
      class Forge
        class RepoV1 < Librarian::Puppet::Source::Forge::Repo

          def initialize(source, name)
            super(source, name)
            # API returned data for this module including all versions and dependencies, indexed by module name
            # from http://forge.puppetlabs.com/api/v1/releases.json?module=#{name}
            @api_data = nil
            # API returned data for this module and a specific version, indexed by version
            # from http://forge.puppetlabs.com/api/v1/releases.json?module=#{name}&version=#{version}
            @api_version_data = {}
          end

          def get_versions
            api_data(name).map { |r| r['version'] }.reverse
          end

          def dependencies(version)
            api_version_data(name, version)['dependencies']
          end

          def url(name, version)
            info = api_version_data(name, version)
            "#{source}#{info[name].first['file']}"
          end

        private

          # Issue #223 dependencies may be duplicated
          # and convert organization/modulename to organization-modulename
          def clear_duplicated_dependencies(data)
            return nil if data.nil?
            data.each do |m,versions|
              versions.each do |v|
                if v["dependencies"] and !v["dependencies"].empty?
                  # convert organization/modulename to organization-modulename
                  v["dependencies"].each {|d| d[0] = normalize_name(d[0])}

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
            # convert organization/modulename to organization-modulename
            data.keys.each do |m|
              if m =~ %r{.*/.*}
                data[normalize_name(m)] = data[m]
                data.delete(m)
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
            url.query = "module=#{module_name.sub('-','/')}" # v1 API expects "organization/module"
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

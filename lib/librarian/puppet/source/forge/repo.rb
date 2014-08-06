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

          def versions
            return @versions if @versions
            @versions = get_versions
            if @versions.empty?
              info { "No versions found for module #{name}" }
            else
              debug { "  Module #{name} found versions: #{@versions.join(", ")}" }
            end
            @versions
          end

          # fetch list of versions ordered for newer to older
          def get_versions
            # implement in subclasses
          end

          # return map with dependencies in the form {module_name => version,...}
          # version: Librarian::Manifest::Version
          def dependencies(version)
            # implement in subclasses
          end

          # return the url for a specific version tarball
          # version: Librarian::Manifest::Version
          def url(name, version)
            # implement in subclasses
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

            unpacked_path = version_unpacked_cache_path(version).join(organization_name(name))

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

            # can't pass the default v3 forge url (http://forgeapi.puppetlabs.com)
            # to clients that use the v1 API (https://forge.puppetlabs.com)
            # nor the other way around
            module_repository = source.to_s

            if Forge.client_api_version() > 1 and module_repository =~ %r{^http(s)?://forge\.puppetlabs\.com}
              module_repository = "https://forgeapi.puppetlabs.com"
              warn { "Replacing Puppet Forge API URL to use v3 #{module_repository} as required by your client version #{Librarian::Puppet.puppet_version}" }
            end

            m = module_repository.match(%r{^http(s)?://forge(api)?\.puppetlabs\.com})
            if Forge.client_api_version() == 1 and m
              ssl = m[1]
              # Puppet 2.7 can't handle the 302 returned by the https url, so stick to http
              if ssl and Librarian::Puppet::puppet_gem_version < Gem::Version.create('3.0.0')
                warn { "Using plain http as your version of Puppet #{Librarian::Puppet::puppet_gem_version} can't download from forge.puppetlabs.com using https" }
                ssl = nil
              end
              module_repository = "http#{ssl}://forge.puppetlabs.com"
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
            url = url(name, version)
            path = vendored_path(name, version).to_s
            debug { "Downloading #{url} into #{path}"}
            environment.vendor!
            File.open(path, 'wb') do |f|
              open(url, "rb") do |input|
                f.write(input.read)
              end
            end
          end

        end
      end
    end
  end
end

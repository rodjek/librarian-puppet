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

          # convert organization/modulename to organization-modulename
          def normalize_dependencies(data)
            return nil if data.nil?
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
            @api_data = normalize_dependencies(api_call(module_name))
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
            @api_version_data[version] = normalize_dependencies(api_call(name, version)) if @api_version_data[version].nil?
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

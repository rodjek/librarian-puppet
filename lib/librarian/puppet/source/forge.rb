require 'uri'
require 'net/http'
require 'json'
require 'librarian/helpers/debug'

module Librarian
  module Puppet
    module Source
      class Forge
        include Helpers::Debug
        class Repo

          include Helpers::Debug
          attr_accessor :source, :name
          private :source=, :name=

          def initialize(source, name)
            self.source = source
            self.name = name
          end

          def versions
            data = api_call("#{name}.json")
            data['releases'].map { |r| r['version'] }.sort.reverse
          end

          def dependencies(version)
            data = api_call("api/v1/releases.json?module=#{name}&version=#{version}")
            data[name].first['dependencies']
          end

          def manifests
            versions.map do |version|
              Manifest.new(source, name, version)
            end
          end

          def install_version!(version, install_path)
            cache_version_unpacked! version

            if install_path.exist?
              debug { "Deleting #{relative_path_to(install_path)}" }
              install_path.rmtree
            end

            unpacked_path = version_unpacked_cache_path(version).join(name.split('/').last)
            debug { "Copying #{relative_path_to(unpacked_path)} to #{relative_path_to(install_path)}" }
            FileUtils.cp_r(unpacked_path, install_path)
          end

          def environment
            source.environment
          end

          def cache_path
            @cache_path ||= source.cache_path.join(name)
          end

          def version_unpacked_cache_path(version)
            cache_path.join('version').join(hexdigest(version.to_s))
          end

          def hexdigest(value)
            Digest::MD5.hexdigest(value)
          end

          def cache_version_unpacked!(version)
            path = version_unpacked_cache_path(version)
            return if path.directory?

            path.mkpath

            output = `puppet module install -i #{path.to_s} --modulepath #{path.to_s} --ignore-dependencies #{name} 2>&1`
            debug { output }
          end

        private

          def api_call(path)
            base_url = source.to_s
            resp = Net::HTTP.get_response(URI.parse("#{base_url}/#{path}"))
            data = resp.body

            JSON.parse(data)
          end
        end

        class << self
          LOCK_NAME = 'FORGE'

          def lock_name
            LOCK_NAME
          end

          def from_lock_options(environment, options)
            new(environment, options[:remote], options.reject { |k, v| k == :remote })
          end

          def from_spec_args(environment, uri, options)
            recognised_options = []
            unrecognised_options = options.keys - recognised_options
            unless unrecognised_options.empty?
              raise Error, "unrecognised options: #{unrecognised_options.join(", ")}"
            end

            new(environment, uri, options)
          end
        end

        attr_accessor :environment
        private :environment=
        attr_reader :uri

        def initialize(environment, uri, options = {})
          self.environment = environment
          @uri = uri
          @cache_path = nil
        end

        def to_s
          uri
        end

        def ==(other)
          other &&
          self.class == other.class &&
          self.uri == other.uri
        end

        def to_spec_args
          [uri, {}]
        end

        def to_lock_options
          {:remote => uri}
        end

        def pinned?
          false
        end

        def unpin!
        end

        def install!(manifest)
          manifest.source == self or raise ArgumentError

          name = manifest.name
          version = manifest.version
          install_path = install_path(name)
          repo = repo(name)

          debug { "Installing #{manifest}" }

          repo.install_version! version, install_path
        end

        def manifest(name, version, dependencies)
          manifest = Manifest.new(self, name)
          manifest.version = version
          manifest.dependencies = dependencies
          manifest
        end

        def cache_path
          @cache_path ||= begin
            dir = Digest::MD5.hexdigest(uri)
            environment.cache_path.join("source/puppet/forge/#{dir}")
          end
        end

        def install_path(name)
          environment.install_path.join(name.split('/').last)
        end

        def fetch_version(name, version_uri)
          versions = repo(name).versions
          if versions.include? version_uri
            version_uri
          else
            versions.first
          end
        end

        def fetch_dependencies(name, version, version_uri)
          repo(name).dependencies(version).map do |k, v|
            Dependency.new(k, v, nil)
          end
        end
      
        def manifests(name)
          repo(name).manifests
        end

      private

        def repo(name)
          @repo ||= {}
          @repo[name] ||= Repo.new(self, name)
        end
      end
    end
  end
end

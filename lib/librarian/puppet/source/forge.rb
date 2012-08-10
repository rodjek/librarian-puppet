require 'uri'
require 'net/http'
require 'json'

module Librarian
  module Puppet
    module Source
      class Forge
        class Repo

          attr_accessor :source, :name
          private :source=, :name=

          def initialize(source, name)
            self.source = source
            self.name = name
          end

          def versions
            data = api_call("#{name}.json")
            if data.nil?
              raise Error, "Unable to find module '#{name}' on #{source}"
            end

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
            if environment.vendor_packages?
              vendor_cache(name, version) unless vendored?(name, version)
            end

            cache_version_unpacked! version

            if install_path.exist?
              install_path.rmtree
            end

            unpacked_path = version_unpacked_cache_path(version).join(name.split('/').last)
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

            target = vendored?(name, version) ? vendored_path(name, version) : name

            `puppet module install --target-dir #{path} --modulepath #{path} --ignore-dependencies #{target}`
          end

          def vendored?(name, version)
            vendored_path(name, version).exist?
          end

          def vendored_path(name, version)
            environment.vendor_cache.join("#{name.sub("/", "-")}-#{version}.tar.gz")
          end

          def vendor_cache(name, version)
            File.open(vendored_path(name, version).to_s, 'w') do |f|
              download(name, version) do |data|
                f << data
              end
            end
          end

          def download(name, version, &block)
            data = api_call("api/v1/releases.json?module=#{name}&version=#{version}")

            info = data[name].detect {|h| h['version'] == version.to_s }

            stream(info['file'], &block)
          end

          def stream(file, &block)
            Net::HTTP.get_response(URI.parse("#{source}#{file}")) do |res|
              res.code

              res.read_body(&block)
            end
          end

        private

          def api_call(path)
            base_url = source.to_s
            resp = Net::HTTP.get_response(URI.parse("#{base_url}/#{path}"))
            if resp.code.to_i != 200
              nil
            else
              data = resp.body
              JSON.parse(data)
            end
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

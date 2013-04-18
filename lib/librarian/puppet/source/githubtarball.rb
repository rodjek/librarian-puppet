require 'uri'
require 'net/https'
require 'json'

module Librarian
  module Puppet
    module Source
      class GitHubTarball
        class Repo

          attr_accessor :source, :name
          private :source=, :name=

          def initialize(source, name)
            self.source = source
            self.name = name
          end

          def versions
            data = api_call("/repos/#{source.uri}/tags")
            if data.nil?
              raise Error, "Unable to find module '#{source.uri}' on https://github.com"
            end

            all_versions = data.map { |r| r['name'] }.sort.reverse

            all_versions = all_versions.map do |version|
              version.gsub(/^v/, '')
            end

            all_versions.delete_if do |version|
              version !~ /\A\d\.\d(\.\d.*)?\z/
            end

            all_versions.compact
          end

          def manifests
            versions.map do |version|
              Manifest.new(source, name, version)
            end
          end

          def install_version!(version, install_path)
            if environment.local? && !vendored?(source.uri, version)
              raise Error, "Could not find a local copy of #{source.uri} at #{version}."
            end

            vendor_cache(source.uri, version) unless vendored?(source.uri, version)

            cache_version_unpacked! version

            if install_path.exist?
              install_path.rmtree
            end

            unpacked_path = version_unpacked_cache_path(version).children.first
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

            target = vendored?(source.uri, version) ? vendored_path(source.uri, version) : name

            `tar xzf #{target} -C #{path}`
          end

          def vendored?(name, version)
            vendored_path(name, version).exist?
          end

          def vendored_path(name, version)
            environment.vendor_cache.mkpath
            environment.vendor_cache.join("#{name.sub("/", "-")}-#{version}.tar.gz")
          end

          def vendor_cache(name, version)
            clean_up_old_cached_versions(name)

            url = "https://api.github.com/repos/#{name}/tarball/#{version}"
            url << "?access_token=#{ENV['GITHUB_API_TOKEN']}" if ENV['GITHUB_API_TOKEN']
            `curl #{url} -o #{vendored_path(name, version).to_s} -L 2>&1`
          end

          def clean_up_old_cached_versions(name)
            Dir["#{environment.vendor_cache}/#{name.sub('/', '-')}*.tar.gz"].each do |old_version|
              FileUtils.rm old_version
            end
          end

        private

          def api_call(path)
            url = "https://api.github.com#{path}"
            url << "?access_token=#{ENV['GITHUB_API_TOKEN']}" if ENV['GITHUB_API_TOKEN']
            uri = URI.parse(url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            request = Net::HTTP::Get.new(uri.request_uri)
            resp = http.request(request)
            if resp.code.to_i != 200
              nil
            else
              data = resp.body
              JSON.parse(data)
            end
          end
        end

        class << self
          LOCK_NAME = 'GITHUBTARBALL'

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

        alias :eql? :==

        def hash
          self.to_s.hash
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
            environment.cache_path.join("source/puppet/githubtarball/#{dir}")
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
          {}
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

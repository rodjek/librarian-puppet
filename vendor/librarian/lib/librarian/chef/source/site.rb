require 'fileutils'
require 'pathname'
require 'uri'
require 'net/http'
require 'json'
require 'digest'
require 'zlib'
require 'securerandom'
require 'archive/tar/minitar'

require 'librarian/chef/manifest_reader'

module Librarian
  module Chef
    module Source
      class Site

        class Line

          attr_accessor :source, :name
          private :source=, :name=

          def initialize(source, name)
            self.source = source
            self.name = name
          end

          def install_version!(version, install_path)
            cache_version_unpacked! version

            if install_path.exist?
              debug { "Deleting #{relative_path_to(install_path)}" }
              install_path.rmtree
            end

            unpacked_path = version_unpacked_cache_path(version)

            debug { "Copying #{relative_path_to(unpacked_path)} to #{relative_path_to(install_path)}" }
            FileUtils.cp_r(unpacked_path, install_path)
          end

          def manifests
            version_uris.map do |version_uri|
              Manifest.new(source, name, version_uri)
            end
          end

          def to_version(version_uri)
            version_uri_metadata(version_uri)["version"]
          end

          def version_dependencies(version)
            version_manifest(version)["dependencies"]
          end

        private

          attr_accessor :metadata_cached
          alias metadata_cached? metadata_cached

          def environment
            source.environment
          end

          def uri
            @uri ||= URI.parse("#{source.uri}/cookbooks/#{name}")
          end

          def version_uris
            metadata["versions"]
          end

          def version_metadata(version)
            version_uri = to_version_uri(version)
            version_uri_metadata(version_uri)
          end

          def version_uri_metadata(version_uri)
            @version_uri_metadata ||= { }
            @version_uri_metadata[version_uri.to_s] ||= begin
              cache_version_uri_metadata! version_uri
              parse_local_json(version_uri_metadata_cache_path(version_uri))
            end
          end

          def version_manifest(version)
            version_uri = to_version_uri(version)
            version_uri_manifest(version_uri)
          end

          def version_uri_manifest(version_uri)
            @version_uri_manifest ||= { }
            @version_uri_manifest[version_uri.to_s] ||= begin
              cache_version_uri_unpacked! version_uri
              unpacked_path = version_uri_unpacked_cache_path(version_uri)
              manifest_path = ManifestReader.manifest_path(unpacked_path)
              ManifestReader.read_manifest(name, manifest_path)
            end
          end

          def metadata
            @metadata ||= begin
              cache_metadata!
              parse_local_json(metadata_cache_path)
            end
          end

          def to_version_uri(version)
            @to_version_uri ||= { }
            @to_version_uri[version.to_s] ||= begin
              cache_version! version
              version_cache_path(version).read
            end
          end

          def metadata_cached!
            self.metadata_cached = true
          end

          def cache_path
            @cache_path ||= source.cache_path.join(name)
          end

          def metadata_cache_path
            @metadata_cache_path ||= cache_path.join("metadata.json")
          end

          def version_cache_path(version)
            @version_cache_path ||= { }
            @version_cache_path[version.to_s] ||= begin
              cache_path.join("version").join(version.to_s)
            end
          end

          def version_uri_cache_path(version_uri)
            @version_uri_cache_path ||= { }
            @version_uri_cache_path[version_uri.to_s] ||= begin
              cache_path.join("version-uri").join(hexdigest(version_uri))
            end
          end

          def version_metadata_cache_path(version)
            version_uri = to_version_uri(version)
            version_uri_metadata_cache_path(version_uri)
          end

          def version_uri_metadata_cache_path(version_uri)
            @version_uri_metadata_cache_path ||= { }
            @version_uri_metadata_cache_path[version_uri.to_s] ||= begin
              version_uri_cache_path(version_uri).join("metadata.json")
            end
          end

          def version_package_cache_path(version)
            version_uri = to_version_uri(version)
            version_uri_package_cache_path(version_uri)
          end

          def version_uri_package_cache_path(version_uri)
            @version_uri_package_cache_path ||= { }
            @version_uri_package_cache_path[version_uri.to_s] ||= begin
              version_uri_cache_path(version_uri).join("package.tar.gz")
            end
          end

          def version_unpacked_cache_path(version)
            version_uri = to_version_uri(version)
            version_uri_unpacked_cache_path(version_uri)
          end

          def version_uri_unpacked_cache_path(version_uri)
            @version_uri_unpacked_cache_path ||= { }
            @version_uri_unpacked_cache_path[version_uri.to_s] ||= begin
              version_uri_cache_path(version_uri).join("package")
            end
          end

          def cache_metadata!
            metadata_cached? and return or metadata_cached!
            cache_remote_json! metadata_cache_path, uri
          end

          def cache_version_uri_metadata!(version_uri)
            path = version_uri_metadata_cache_path(version_uri)
            path.file? and return

            cache_remote_json! path, version_uri
          end

          def cache_version!(version)
            path = version_cache_path(version)
            path.file? and return

            version_uris.each do |version_uri|
              m = version_uri_metadata(version_uri)
              v = m["version"]
              if version.to_s == v
                write! path, version_uri.to_s
                break
              end
            end
          end

          def cache_version_package!(version)
            version_uri = to_version_uri(version)
            cache_version_uri_package! version_uri
          end

          def cache_version_uri_package!(version_uri)
            path = version_uri_package_cache_path(version_uri)
            path.file? and return

            file_uri = version_uri_metadata(version_uri)["file"]
            cache_remote_object! path, file_uri
          end

          def cache_version_unpacked!(version)
            version_uri = to_version_uri(version)
            cache_version_uri_unpacked! version_uri
          end

          def cache_version_uri_unpacked!(version_uri)
            cache_version_uri_package!(version_uri)

            path = version_uri_unpacked_cache_path(version_uri)
            path.directory? and return

            package_path = version_uri_package_cache_path(version_uri)
            unpacked_path = version_uri_unpacked_cache_path(version_uri)

            unpack_package! unpacked_path, package_path
          end

          def cache_remote_json!(path, uri)
            path = Pathname(path)
            uri = to_uri(uri)

            path.dirname.mkpath unless path.dirname.directory?

            debug { "Caching #{uri} to #{path}" }

            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Get.new(uri.path)
            response = http.start{|http| http.request(request)}
            unless Net::HTTPSuccess === response
              raise Error, "Could not get #{uri} because #{response.code} #{response.message}!"
            end
            json = response.body
            JSON.parse(json) # verify that it's really JSON.
            write! path, json
          end

          def cache_remote_object!(path, uri)
            path = Pathname(path)
            uri = to_uri(uri)

            path.dirname.mkpath unless path.dirname.directory?

            debug { "Caching #{uri} to #{path}" }

            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Get.new(uri.path)
            response = http.start{|http| http.request(request)}
            unless Net::HTTPSuccess === response
              raise Error, "Could not get #{uri} because #{response.code} #{response.message}!"
            end
            write! path, response.body
          end

          def write!(path, bytes)
            path.dirname.mkpath
            path.open("wb"){|f| f.write(bytes)}
          end

          def unpack_package!(path, source)
            path = Pathname(path)
            source = Pathname(source)

            temp = environment.scratch_path.join(SecureRandom.hex(16))
            temp.mkpath

            debug { "Unpacking #{relative_path_to(source)} to #{relative_path_to(temp)}" }
            Zlib::GzipReader.open(source) do |input|
              Archive::Tar::Minitar.unpack(input, temp.to_s)
            end

            # Cookbook files, as pulled from Opscode Community Site API, are
            # embedded in a subdirectory of the tarball, and the subdirectory's
            # name is equal to the name of the cookbook.
            subtemp = temp.join(name)
            debug { "Moving #{relative_path_to(subtemp)} to #{relative_path_to(path)}" }
            FileUtils.mv(subtemp, path)
          ensure
            temp.rmtree if temp && temp.exist?
          end

          def parse_local_json(path)
            JSON.parse(path.read)
          end

          def hexdigest(bytes)
            Digest::MD5.hexdigest(bytes)
          end

          def to_uri(uri)
            uri = URI(uri) unless URI === uri
            uri
          end

          def debug(*args, &block)
            environment.logger.debug(*args, &block)
          end

          def relative_path_to(path)
            environment.logger.relative_path_to(path)
          end

        end

        class << self

          LOCK_NAME = 'SITE'

          def lock_name
            LOCK_NAME
          end

          def from_lock_options(environment, options)
            new(environment, options[:remote], options.reject{|k, v| k == :remote})
          end

          def from_spec_args(environment, uri, options)
            recognized_options = []
            unrecognized_options = options.keys - recognized_options
            unrecognized_options.empty? or raise Error, "unrecognized options: #{unrecognized_options.join(", ")}"

            new(environment, uri, options)
          end

        end

        attr_accessor :environment
        private :environment=
        attr_reader :uri

        attr_accessor :_metadata_cache
        private :_metadata_cache, :_metadata_cache=

        def initialize(environment, uri, options = {})
          self.environment = environment
          @uri = uri
          @cache_path = nil
          self._metadata_cache = { }
        end

        def to_s
          uri
        end

        def ==(other)
          other &&
          self.class  == other.class &&
          self.uri    == other.uri
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
          line = line(name)

          info { "Installing #{manifest.name} (#{manifest.version})" }

          debug { "Installing #{manifest}" }

          line.install_version! version, install_path
        end

        # NOTE:
        #   Assumes the Opscode Site API responds with versions in reverse sorted order
        def manifests(name)
          line(name).manifests
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
            environment.cache_path.join("source/chef/site/#{dir}")
          end
        end

        def install_path(name)
          environment.install_path.join(name)
        end

        def fetch_version(name, version_uri)
          line(name).to_version(version_uri)
        end

        def fetch_dependencies(name, version, version_uri)
          line(name).version_dependencies(version).map{|k, v| Dependency.new(k, v, nil)}
        end

      private

        def line(name)
          @line ||= { }
          @line[name] ||= Line.new(self, name)
        end

        def info(*args, &block)
          environment.logger.info(*args, &block)
        end

        def debug(*args, &block)
          environment.logger.debug(*args, &block)
        end

      end
    end
  end
end

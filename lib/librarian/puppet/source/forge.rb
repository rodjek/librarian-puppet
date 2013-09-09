require 'json'
require 'open-uri'

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
            @api_data = nil
          end

          def versions
            return @versions if @versions
            versions = api_data[name].map { |r| r['version'] }.reverse
            debug { "  Module #{name} found versions: #{versions.join(", ")}" }
            versions.select { |v| ! Gem::Version.correct? v }.each { |v| debug { "Ignoring invalid version '#{v}' for module #{name}" } }
            @versions = versions.select { |v| Gem::Version.correct? v }
            @versions
          end

          def dependencies(version)
            api_data[name].detect{|x| x['version'] == version.to_s}['dependencies']
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
              FileUtils.cp_r(unpacked_path, install_path)
            end

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

            # The puppet module command is only available from puppet versions >= 2.7.13
            #
            # Specifying the version in the gemspec would force people to upgrade puppet while it's still usable for git
            # So we do some more clever checking
            #
            # Executing older versions or via puppet-module tool gives an exit status = 0 .
            #
            check_puppet_module_options

            path.mkpath

            target = vendored?(name, version) ? vendored_path(name, version) : name


            command = "puppet module install --version #{version} --target-dir '#{path}' --module_repository '#{source}' --modulepath '#{path}' --ignore-dependencies '#{target}'"
            debug { "Executing puppet module install for #{name} #{version}" }
            output = `#{command}`

            # Check for bad exit code
            unless $? == 0
              # Rollback the directory if the puppet module had an error
              path.unlink
              raise Error, "Error executing puppet module install:\n#{command}\nError:\n#{output}"
            end
          end

          def check_puppet_module_options
            min_version    = Gem::Version.create('2.7.13')
            puppet_version = Gem::Version.create(`puppet --version`.split(' ').first.strip.gsub('-', '.'))

            if puppet_version < min_version
              raise Error, "To get modules from the forge, we use the puppet faces module command. For this you need at least puppet version 2.7.13 and you have #{puppet_version}"
            end
          end

          def vendored?(name, version)
            vendored_path(name, version).exist?
          end

          def vendored_path(name, version)
            environment.vendor_cache.join("#{name.sub("/", "-")}-#{version}.tar.gz")
          end

          def vendor_cache(name, version)
            info = api_data[name].detect {|h| h['version'] == version.to_s }
            File.open(vendored_path(name, version).to_s, 'w') do |f|
              open("#{source}#{info['file']}") do |input|
                while (buffer = input.read)
                  f.write(buffer)
                end
              end
            end
          end

          def debug(*args, &block)
            environment.logger.debug(*args, &block)
          end

        private
          def api_data
            return @api_data if @api_data
            # call API and cache data
            @api_data = api_call(name)
            if @api_data.nil?
              raise Error, "Unable to find module '#{name}' on #{source}"
            end
            @api_data
          end

          def api_call(module_name)
            debug { "Querying Forge API for module #{name}" }
            base_url = source.uri
            path     = "api/v1/releases.json?module=#{module_name}"
            
            begin
              data = open("#{base_url}/#{path}") {|f| f.read}
              JSON.parse(data)
            rescue OpenURI::HTTPError => e
              case e.io.status[0].to_i
              when 404,410
                nil
              else
                raise e, "Error requesting #{base_url}/#{path}: #{e.to_s}"
              end
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
        alias eql? ==

        def hash
          self.uri.hash
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
          environment.logger.debug { "      Fetching dependencies for #{name} #{version}" }
          repo(name).dependencies(version).map do |k, v|
            begin
              v = Requirement.new(v).gem_requirement
              Dependency.new(k, v, nil)
            rescue ArgumentError => e
              raise Error, "Error fetching dependency for #{name} [#{version}]: #{k} [#{v}]: #{e}"
            end
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

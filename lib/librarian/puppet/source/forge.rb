require 'uri'
require 'librarian/puppet/util'
require 'librarian/puppet/source/forge/repo_v1'
# require 'librarian/puppet/source/forge/repo_v3'

module Librarian
  module Puppet
    module Source
      class Forge
        include Librarian::Puppet::Util

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

          def client_api_version()
            version = 1
            pe_version = Librarian::Puppet.puppet_version.match(/\(Puppet Enterprise (.+)\)/)

            # Puppet 3.6.0+ uses api v3
            if Librarian::Puppet::puppet_gem_version >= Gem::Version.create('3.6.0.a')
              version = 3
            # Puppet enterprise 3.2.0+ uses api v3
            elsif pe_version and Gem::Version.create(pe_version[1].strip) >= Gem::Version.create('3.2.0')
              version = 3
            end
            return version
          end

        end

        attr_accessor :environment
        private :environment=
        attr_reader :uri

        def initialize(environment, uri, options = {})
          self.environment = environment

          # if uri =~ %r{^http(s)?://forge\.puppetlabs\.com}
          #   uri = "https://forgeapi.puppetlabs.com"
          #   warn { "Replacing Puppet Forge API URL to use v3 #{uri}. You should update your Puppetfile" }
          # end

          @uri = URI::parse(uri)
          @cache_path = nil
        end

        def to_s
          clean_uri(uri).to_s
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
          [clean_uri(uri).to_s, {}]
        end

        def to_lock_options
          {:remote => clean_uri(uri).to_s}
        end

        def pinned?
          false
        end

        def unpin!
        end

        def install!(manifest)
          manifest.source == self or raise ArgumentError

          debug { "Installing #{manifest}" }

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
            dir = "#{uri.host}#{uri.path}".gsub(/[^0-9a-z\-_]/i, '_')
            environment.cache_path.join("source/puppet/forge/#{dir}")
          end
        end

        def install_path(name)
          environment.install_path.join(organization_name(name))
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
            v = Requirement.new(v).gem_requirement
            Dependency.new(k, v, nil)
          end
        end

        def manifests(name)
          repo(name).manifests
        end

      private

        def repo(name)
          @repo ||= {}

          unless @repo[name]
            # if we are using the official Forge then use API v3, otherwise stick to v1 for now
            # if uri.hostname =~ /\.puppetlabs\.com$/ || !environment.use_v1_api
            #   @repo[name] = RepoV3.new(self, name)
            # else
              @repo[name] = RepoV1.new(self, name)
            # end
          end
          @repo[name]
        end
      end
    end
  end
end

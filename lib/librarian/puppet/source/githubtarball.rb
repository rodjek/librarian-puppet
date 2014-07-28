require 'uri'
require 'librarian/puppet/util'
require 'librarian/puppet/source/githubtarball/repo'

module Librarian
  module Puppet
    module Source
      class GitHubTarball
        include Librarian::Puppet::Util

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
            environment.cache_path.join("source/puppet/githubtarball/#{uri.host}#{uri.path}")
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

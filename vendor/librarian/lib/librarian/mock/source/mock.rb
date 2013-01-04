require 'librarian/manifest'
require 'librarian/mock/source/mock/registry'

module Librarian
  module Mock
    module Source
      class Mock

        class << self

          LOCK_NAME = 'MOCK'

          def lock_name
            LOCK_NAME
          end

          def from_lock_options(environment, options)
            new(environment, options[:remote], options.reject{|k, v| k == :remote})
          end

          def from_spec_args(environment, name, options)
            recognized_options = []
            unrecognized_options = options.keys - recognized_options
            unrecognized_options.empty? or raise Error, "unrecognized options: #{unrecognized_options.join(", ")}"

            new(environment, name, options)
          end

        end

        attr_accessor :environment
        private :environment=
        attr_reader :name

        def initialize(environment, name, options)
          self.environment = environment
          @name = name
        end

        def to_s
          name
        end

        def ==(other)
          other &&
          self.class  == other.class &&
          self.name   == other.name
        end

        alias :eql? :==

        def hash
          self.to_s.hash
        end

        def to_spec_args
          [name, {}]
        end

        def to_lock_options
          {:remote => name}
        end

        def registry
          environment.registry[name]
        end

        def manifest(name, version, dependencies)
          manifest = Manifest.new(self, name)
          manifest.version = version
          manifest.dependencies = dependencies
          manifest
        end

        def manifests(name)
          if d = registry[name]
            d.map{|v| manifest(name, v[:version], v[:dependencies])}
          else
            nil
          end
        end

        def install!(manifest)
        end

        def to_s
          name
        end

        def fetch_version(name, extra)
          extra
        end

        def fetch_dependencies(name, version, extra)
          d = registry[name]
          m = d.find{|v| v[:version] == version.to_s}
          m[:dependencies]
        end

      end
    end
  end
end

require 'librarian/manifest'
require 'librarian/dependency'
require 'librarian/manifest_set'

module Librarian
  class Lockfile
    class Parser

      class ManifestPlaceholder
        attr_reader :source, :name, :version, :dependencies
        def initialize(source, name, version, dependencies)
          @source, @name, @version, @dependencies = source, name, version, dependencies
        end
      end

      attr_accessor :environment
      private :environment=

      def initialize(environment)
        self.environment = environment
      end

      def parse(string)
        string = string.dup
        source_type_names_map = Hash[dsl_class.source_types.map{|t| [t[1].lock_name, t[1]]}]
        source_type_names = dsl_class.source_types.map{|t| t[1].lock_name}
        lines = string.split(/(\r|\n|\r\n)+/).select{|l| l =~ /\S/}
        sources = []
        while source_type_names.include?(lines.first)
          source = {}
          source_type_name = lines.shift
          source[:type] = source_type_names_map[source_type_name]
          options = {}
          while lines.first =~ /^ {2}([\w-]+):\s+(.+)$/
            lines.shift
            options[$1.to_sym] = $2
          end
          source[:options] = options
          lines.shift # specs
          manifests = {}
          while lines.first =~ /^ {4}([\w-]+) \((.*)\)$/
            lines.shift
            name = $1
            manifests[name] = {:version => $2, :dependencies => {}}
            while lines.first =~ /^ {6}([\w-]+) \((.*)\)$/
              lines.shift
              manifests[name][:dependencies][$1] = $2.split(/,\s*/)
            end
          end
          source[:manifests] = manifests
          sources << source
        end
        manifests = compile(sources)
        manifests_index = Hash[manifests.map{|m| [m.name, m]}]
        raise StandardError, "Expected DEPENDENCIES topic!" unless lines.shift == "DEPENDENCIES"
        dependencies = []
        while lines.first =~ /^ {2}([\w-]+)(?: \((.*)\))?$/
          lines.shift
          name, requirement = $1, $2.split(/,\s*/)
          dependencies << Dependency.new(name, requirement, manifests_index[name].source)
        end
        Resolution.new(dependencies, manifests)
      end

    private

      def compile(sources_ast)
        manifests = {}
        sources_ast.each do |source_ast|
          source_type = source_ast[:type]
          source = source_type.from_lock_options(environment, source_ast[:options])
          source_ast[:manifests].each do |manifest_name, manifest_ast|
            manifests[manifest_name] = ManifestPlaceholder.new(
              source,
              manifest_name,
              manifest_ast[:version],
              manifest_ast[:dependencies].map{|k, v| Dependency.new(k, v, nil)}
            )
          end
        end
        manifests = manifests.map do |name, manifest|
          dependencies = manifest.dependencies.map do |d|
            Dependency.new(d.name, d.requirement, manifests[d.name].source)
          end
          manifest.source.manifest(
            manifest.name,
            manifest.version,
            dependencies
          )
        end
        ManifestSet.sort(manifests)
      end

      def dsl_class
        environment.dsl_class
      end

    end
  end
end

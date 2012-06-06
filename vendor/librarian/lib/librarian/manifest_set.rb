require 'set'
require 'tsort'

module Librarian
  class ManifestSet

    class GraphHash < Hash
      include TSort
      alias tsort_each_node each_key
      def tsort_each_child(node, &block)
        self[node].each(&block)
      end
    end

    class << self
      def shallow_strip(manifests, names)
        new(manifests).shallow_strip!(names).send(method_for(manifests))
      end
      def deep_strip(manifests, names)
        new(manifests).deep_strip!(names).send(method_for(manifests))
      end
      def shallow_keep(manifests, names)
        new(manifests).shallow_keep!(names).send(method_for(manifests))
      end
      def deep_keep(manifests, names)
        new(manifests).deep_keep!(names).send(method_for(manifests))
      end
      def sort(manifests)
        manifests = Hash[manifests.map{|m| [m.name, m]}] if Array === manifests
        manifest_pairs = GraphHash[manifests.map{|k, m| [k, m.dependencies.map{|d| d.name}]}]
        manifest_names = manifest_pairs.tsort
        manifest_names.map{|n| manifests[n]}
      end
    private
      def method_for(manifests)
        case manifests
        when Hash
          :to_hash
        when Array
          :to_a
        end
      end
    end

    def initialize(manifests)
      self.index = Hash === manifests ? manifests.dup : Hash[manifests.map{|m| [m.name, m]}]
    end

    def to_a
      index.values
    end

    def to_hash
      index.dup
    end

    def dup
      self.class.new(index)
    end

    def shallow_strip(names)
      dup.shallow_strip!(names)
    end

    def shallow_strip!(names)
      assert_strings!(names)

      names.each do |name|
        index.delete(name)
      end
      self
    end

    def deep_strip(names)
      dup.deep_strip!(names)
    end

    def deep_strip!(names)
      names = Array === names ? names.dup : names.to_a
      assert_strings!(names)

      strippables = dependencies_of(names)
      shallow_strip!(strippables)

      self
    end

    def shallow_keep(names)
      dup.shallow_keep!(names)
    end

    def shallow_keep!(names)
      assert_strings!(names)

      names = Set.new(names) unless Set === names
      index.reject! { |k, v| !names.include?(k) }
      self
    end

    def deep_keep(names)
      dup.conservative_strip!(names)
    end

    def deep_keep!(names)
      names = Array === names ? names.dup : names.to_a
      assert_strings!(names)

      keepables = dependencies_of(names)
      shallow_keep!(keepables)

      self
    end

    def consistent?
      index.values.all? do |manifest|
        in_compliance_with?(manifest.dependencies)
      end
    end

    def in_compliance_with?(dependencies)
      dependencies.all? do |dependency|
        manifest = index[dependency.name]
        manifest && manifest.satisfies?(dependency)
      end
    end

  private

    attr_accessor :index

    def assert_strings!(names)
      non_strings = names.reject{|name| String === name}
      non_strings.empty? or raise TypeError, "names must all be strings"
    end

    # Straightforward breadth-first graph traversal algorithm.
    def dependencies_of(names)
      names = Array === names ? names.dup : names.to_a
      assert_strings!(names)

      deps = Set.new
      until names.empty?
        name = names.shift
        next if deps.include?(name)

        deps << name
        names.concat index[name].dependencies.map(&:name)
      end
      deps.to_a
    end

  end
end

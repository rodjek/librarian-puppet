require 'librarian/spec'

module Librarian
  class Dsl
    class Target

      class SourceShortcutDefinitionReceiver
        def initialize(target)
          singleton_class = class << self; self end
          singleton_class.class_eval do
            define_method(:source) do |options|
              target.source_from_options(options)
            end
            target.source_types.each do |source_type|
              name = source_type[0]
              define_method(name) do |*args|
                args.push({}) unless Hash === args.last
                target.source_from_params(name, *args)
              end
            end
          end
        end
      end

      SCOPABLES = [:sources]

      attr_accessor :dsl
      private :dsl=

      attr_reader :dependency_name, :dependency_type
      attr_reader :source_types, :source_types_map, :source_types_reverse_map, :source_type_names, :source_shortcuts
      attr_reader :dependencies, :source_cache, *SCOPABLES

      def initialize(dsl)
        self.dsl = dsl
        @dependency_name = dsl.dependency_name
        @dependency_type = dsl.dependency_type
        @source_types = dsl.source_types
        @source_types_map = Hash[source_types]
        @source_types_reverse_map = Hash[source_types.map{|pair| a, b = pair ; [b, a]}]
        @source_type_names = source_types.map{|t| t[0]}
        @source_cache = {}
        @source_shortcuts = {}
        @dependencies = []
        SCOPABLES.each do |scopable|
          instance_variable_set(:"@#{scopable}", [])
        end
        dsl.source_shortcuts.each do |name, param|
          define_source_shortcut(name, param)
        end
      end

      def to_spec
        Spec.new(@sources.first, @dependencies)
      end

      def dependency(name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source = source_from_options(options) || @sources.last
        unless source
          raise Error, "#{dependency_name} #{name} is specified without a source!"
        end
        dep = dependency_type.new(name, args, source)
        @dependencies << dep
      end

      def source(name, param = nil, options = nil, &block)
        if !(Hash === name) && [Array, Hash, Proc].any?{|c| c === param} && !options && !block
          define_source_shortcut(name, param)
        elsif !(Hash === name) && !param && !options
          source = source_shortcuts[name]
          scope_or_directive(block) do
            @sources = @sources.dup << source
          end
        else
          name, param, options = *normalize_source_options(name, param, options || {})
          source = source_from_params(name, param, options)
          scope_or_directive(block) do
            @sources = @sources.dup << source
          end
        end
      end

      def precache_sources(sources)
        sources.each do |source|
          key = [source_types_reverse_map[source.class], *source.to_spec_args]
          source_cache[key] = source
        end
      end

      def scope
        currents = { }
        SCOPABLES.each do |scopable|
          currents[scopable] = instance_variable_get(:"@#{scopable}").dup
        end
        yield
      ensure
        SCOPABLES.reverse.each do |scopable|
          instance_variable_set(:"@#{scopable}", currents[scopable])
        end
      end

      def scope_or_directive(scoped_block = nil)
        unless scoped_block
          yield
        else
          scope do
            yield
            scoped_block.call
          end
        end
      end

      def normalize_source_options(name, param, options)
        if name.is_a?(Hash)
          extract_source_parts(name)
        else
          [name, param, options]
        end
      end

      def extract_source_parts(options)
        if name = source_type_names.find{|name| options.key?(name)}
          options = options.dup
          param = options.delete(name)
          [name, param, options]
        else
          nil
        end
      end

      def source_from_options(options)
        if options[:source]
          source_shortcuts[options[:source]]
        elsif source_parts = extract_source_parts(options)
          source_from_params(*source_parts)
        else
          nil
        end
      end

      def source_from_params(name, param, options)
        source_cache[[name, param, options]] ||= begin
          type = source_types_map[name]
          type.from_spec_args(environment, param, options)
        end
      end

      def source_from_source_shortcut_definition(definition)
        case definition
        when Array
          source_from_params(*definition)
        when Hash
          source_from_options(definition)
        when Proc
          receiver = SourceShortcutDefinitionReceiver.new(self)
          receiver.instance_eval(&definition)
        end
      end

      def define_source_shortcut(name, definition)
        source = source_from_source_shortcut_definition(definition)
        source_shortcuts[name] = source
      end

      def environment
        dsl.environment
      end

    end
  end
end

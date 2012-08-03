require 'rubygems'

module Librarian
  class Dependency

    class Requirement
      def initialize(*args)
        args = initialize_normalize_args(args)

        self.backing = Gem::Requirement.create(*args)
      end

      def to_gem_requirement
        backing
      end

      def satisfied_by?(version)
        to_gem_requirement.satisfied_by?(version.to_gem_version)
      end

      def ==(other)
        to_gem_requirement == other.to_gem_requirement
      end

      def to_s
        to_gem_requirement.to_s
      end

      protected

      attr_accessor :backing

      private

      def initialize_normalize_args(args)
        args.map do |arg|
          arg = arg.backing if self.class === arg
          arg
        end
      end
    end

    attr_accessor :name, :requirement, :source
    private :name=, :requirement=, :source=

    def initialize(name, requirement, source)
      assert_name_valid! name

      self.name = name
      self.requirement = Requirement.new(requirement)
      self.source = source

      @manifests = nil
    end

    def manifests
      @manifests ||= cache_manifests!
    end

    def cache_manifests!
      source.manifests(name)
    end

    def satisfied_by?(manifest)
      manifest.satisfies?(self)
    end

    def to_s
      "#{name} (#{requirement}) <#{source}>"
    end

    def ==(other)
      !other.nil? &&
      self.class        == other.class        &&
      self.name         == other.name         &&
      self.requirement  == other.requirement  &&
      self.source       == other.source
    end

  private

    def environment
      source.environment
    end

    def assert_name_valid!(name)
      raise ArgumentError, "name (#{name.inspect}) must be sensible" unless name =~ /\A\S(?:.*\S)?\z/
    end

  end
end

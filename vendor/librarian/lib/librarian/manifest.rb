require 'rubygems'

module Librarian
  class Manifest

    class PreReleaseVersion

      # Compares pre-release component ids using Semver 2.0.0 spec
      def self.compare_components(this_id,other_id)
        case # Strings have higher precedence than numbers
          when (this_id.is_a?(Integer) and other_id.is_a?(String))
            -1
          when (this_id.is_a?(String) and other_id.is_a?(Integer))
            1
          else
            this_id <=> other_id
        end
      end

      # Parses pre-release components `a.b.c` into an array ``[a,b,c]`
      # Converts numeric components into +Integer+
      def self.parse(prerelease)
        if prerelease.nil?
          []
        else
          prerelease.split('.').collect do |id|
            id = Integer(id) if /^[0-9]+$/ =~ id
            id
          end
        end
      end

      include Comparable

      attr_reader :components

      def initialize(prerelease)
        @prerelease = prerelease
        @components = PreReleaseVersion.parse(prerelease)
      end

      def to_s
        @prerelease
      end

      def <=>(other)
        # null-fill zip array to prevent loss of components
        z = Array.new([components.length,other.components.length])

        # Compare each component against the other
        comp = z.zip(components,other.components).collect do |ids|
          case # All components being equal, the version with more of them takes precedence
            when ids[1].nil? # Self has less elements, other wins
              -1
            when ids[2].nil? # Other has less elements, self wins
              1
            else
              PreReleaseVersion.compare_components(ids[1],ids[2])
          end
        end
        # Chose the first non-zero comparison or return 0
        comp.delete_if {|c| c == 0}[0] || 0
      end
    end
    class Version
      @@SEMANTIC_VERSION_PATTERN = /^([0-9]+\.[0-9]+(?:\.[0-9]+)?)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/
      def self.parse_semver(version_string)
        parsed = @@SEMANTIC_VERSION_PATTERN.match(version_string.strip)
        if parsed
          {
            :full_version => parsed[0],
            :version => parsed[1],
            :prerelease => (PreReleaseVersion.new(parsed[2]) if parsed[2]),
            :build => parsed[3]
          }
        end
      end
      include Comparable

      attr_reader :prerelease

      def initialize(*args)
        args = initialize_normalize_args(args)
        semver = Version.parse_semver(*args)
        if semver
          self.backing  = Gem::Version.new(semver[:version])
          @prerelease   = semver[:prerelease]
          @full_version = semver[:full_version]
        else
          self.backing  = Gem::Version.new(*args)
          @full_version = to_gem_version.to_s
        end
      end

      def to_gem_version
        backing
      end

      def <=>(other)
        cmp = to_gem_version <=> other.to_gem_version

        # Should compare pre-release versions?
        if cmp == 0 and not (prerelease.nil? and other.prerelease.nil?)
          case # Versions without prerelease take precedence
            when (prerelease.nil? and not other.prerelease.nil?)
              1
            when (not prerelease.nil? and other.prerelease.nil?)
              -1
            else
              prerelease <=> other.prerelease
          end
        else
          cmp
        end
      end

      def to_s
        @full_version
      end

      private

      def initialize_normalize_args(args)
        args.map do |arg|
          arg = [arg] if self.class === arg
          arg
        end
      end

      attr_accessor :backing
    end

    attr_accessor :source, :name, :extra
    private :source=, :name=, :extra=

    def initialize(source, name, extra = nil)
      assert_name_valid! name

      self.source = source
      self.name = name
      self.extra = extra
    end

    def to_s
      "#{name}/#{version} <#{source}>"
    end

    def version
      defined_version || fetched_version
    end

    def version=(version)
      self.defined_version = _normalize_version(version)
    end

    def version?
      return unless defined_version

      defined_version == fetched_version
    end

    def latest
      @latest ||= source.manifests(name).first
    end

    def outdated?
      latest.version > version
    end

    def dependencies
      defined_dependencies || fetched_dependencies
    end

    def dependencies=(dependencies)
      self.defined_dependencies = _normalize_dependencies(dependencies)
    end

    def dependencies?
      return unless defined_dependencies

      defined_dependencies.zip(fetched_dependencies).all? do |(a, b)|
        a.name == b.name && a.requirement == b.requirement
      end
    end

    def satisfies?(dependency)
      dependency.requirement.satisfied_by?(version)
    end

    def install!
      source.install!(self)
    end

  private

    attr_accessor :defined_version, :defined_dependencies

    def environment
      source.environment
    end

    def fetched_version
      @fetched_version ||= _normalize_version(fetch_version!)
    end

    def fetched_dependencies
      @fetched_dependencies ||= _normalize_dependencies(fetch_dependencies!)
    end

    def fetch_version!
      source.fetch_version(name, extra)
    end

    def fetch_dependencies!
      source.fetch_dependencies(name, version, extra)
    end

    def _normalize_version(version)
      Version.new(version)
    end

    def _normalize_dependencies(dependencies)
      if Hash === dependencies
        dependencies = dependencies.map{|k, v| Dependency.new(k, v, nil)}
      end
      dependencies.sort_by(&:name)
    end

    def assert_name_valid!(name)
      raise ArgumentError, "name (#{name.inspect}) must be sensible" unless name =~ /\A\S(?:.*\S)?\z/
    end

  end
end

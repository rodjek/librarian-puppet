require 'rubygems'

module Librarian
  class Manifest

    class Version
      @@SEMANTIC_VERSION_PATTERN = /^([0-9]+\.[0-9]+(?:\.[0-9]+)?)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/
      def self.parse(version_string)
        parsed = @@SEMANTIC_VERSION_PATTERN.match(version_string.strip)
        raise ArgumentError, "Invalid Semantic Version String '#{version_string}'" unless parsed
        {
            :full_version   => parsed[0],
            :version        => parsed[1],
            :prerelease     => parsed[2],
            :build          => parsed[3],
            :prerelease_ids => self.parse_metadata(parsed[2])
        }
      end

      def self.parse_metadata(metadata)
        if metadata.nil?
          []
        else
          metadata.split('.').collect do |id|
            id = Integer(id) if /^[0-9]+$/ =~ id
            id
          end
        end
      end

      # Compare Pre-release Ids
      def self.compare_ids(id1,id2)
        if id1.is_a?(Integer) or id2.is_a?(Integer)
          # Numeric ids have lower precedence than alpha ids
          if id1.is_a?(String)
            return 1
          elsif id2.is_a?(String)
            return -1
          end
        end
        id1 <=> id2
      end

      include Comparable

      attr_reader :prerelease_ids
      attr_reader :prerelease
      attr_reader :full_version

      def initialize(version)
        semver = Version.parse(version)
        self.backing    = Gem::Version.new(semver[:version])
        @full_version   = semver[:full_version]
        @prerelease     = semver[:prerelease]
        @prerelease_ids = semver[:prerelease_ids]
      end

      def has_prerelease?
        not @prerelease.nil?
      end

      def to_gem_version
        backing
      end

      def <=>(other)
        version_compare = to_gem_version <=> other.to_gem_version
        if version_compare == 0 and (has_prerelease? or other.has_prerelease?)
          # Versions without a prerelease version win over those which have one
          if not has_prerelease? and other.has_prerelease?  # My version wins
            1
          elsif not other.has_prerelease? and has_prerelease? # Their version wins
            -1
          else # Both have pre-release versions; comparison is mandatory
            z = Array.new([prerelease_ids.length,other.prerelease_ids.length].max)
            (z.zip(prerelease_ids,other.prerelease_ids).collect { |ids|
              if ids[1].nil? # self has less elements, other wins
                -1
              elsif ids[2].nil? # other has less elements, self wins
                1
              else
                Version.compare_ids(ids[1],ids[2]) # Normal comparison of ids
              end
            }).delete_if {|c| c == 0}[0] || 0
          end
        else
          version_compare
        end
      end

      def to_s
        if has_prerelease?
          "#{to_gem_version.to_s}-#{@prerelease}"
        else
          to_gem_version.to_s
        end
      end

      private

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

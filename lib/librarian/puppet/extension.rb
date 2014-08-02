require 'librarian/puppet/environment'
require 'librarian/action/base'

module Librarian
  module Puppet
    extend self
    extend Librarian
  end

  class Dependency
    include Librarian::Puppet::Util

    def initialize(name, requirement, source)
      assert_name_valid! name

      # Issue #235 fail if forge source is not defined
      raise Error, "forge entry is not defined in Puppetfile" if source.instance_of?(Array) && source.empty?

      # let's settle on provider-module syntax instead of provider/module
      self.name = normalize_name(name)
      self.requirement = Requirement.new(requirement)
      self.source = source

      @manifests = nil
    end

    class Requirement
      def initialize(*args)
        args = initialize_normalize_args(args)
        self.backing = Gem::Requirement.create(puppet_to_gem_versions(args))
      end

      def puppet_to_gem_versions(args)
        args.map do |arg|
          case arg
          when Array
            arg.map { |v| Librarian::Puppet::Requirement.new(v).gem_requirement }
          when String
            Librarian::Puppet::Requirement.new(arg).gem_requirement
          else
            # Gem::Requirement, convert to string (ie. =1.0) so we can concat later
            # Gem::Requirements can not be concatenated
            arg.requirements.map{|x,y| "#{x}#{y}"}
          end
        end.flatten
      end
    end

    alias :eql? :==

    def hash
      self.to_s.hash
    end
  end

  # Fixes for librarian not yet released in their gem
  module Mock
    module Source
      class Mock
        alias :eql? :==

        def hash
          self.to_s.hash
        end
      end
    end
  end
  module Source
    class Git
      alias :eql? :==

      def hash
        self.to_s.hash
      end
    end

    class Path
      alias :eql? :==

      def hash
        self.to_s.hash
      end
    end
  end

  class ManifestSet
    include Librarian::Puppet::Util

    private

    # Check if module doesn't exist and fail fast
    def dependencies_of(names)
      names = Array === names ? names.dup : names.to_a
      assert_strings!(names)

      deps = Set.new
      until names.empty?
        name = normalize_name(names.shift)
        next if deps.include?(name)

        deps << name
        raise(Error, "Unable to find module #{name}") if index[name].nil?
        names.concat index[name].dependencies.map(&:name)
      end
      deps.to_a
    end
  end

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
    end
  end

  class Logger
    def warn(string = nil, &block)
      return unless ui

      ui.warn(string || yield)
    end
  end
end

require 'librarian/helpers'

require 'librarian/manifest_set'
require 'librarian/resolution'
require 'librarian/spec'

module Librarian
  class SpecChangeSet

    attr_accessor :environment
    private :environment=
    attr_reader :spec, :lock

    def initialize(environment, spec, lock)
      self.environment = environment
      raise TypeError, "can't convert #{spec.class} into #{Spec}" unless Spec === spec
      raise TypeError, "can't convert #{lock.class} into #{Resolution}" unless Resolution === lock
      @spec, @lock = spec, lock
    end

    def same?
      @same ||= spec.dependencies.sort_by{|d| d.name} == lock.dependencies.sort_by{|d| d.name}
    end

    def changed?
      !same?
    end

    def spec_dependencies
      @spec_dependencies ||= spec.dependencies
    end
    def spec_dependency_names
      @spec_dependency_names ||= Set.new(spec_dependencies.map{|d| d.name})
    end
    def spec_dependency_index
      @spec_dependency_index ||= Hash[spec_dependencies.map{|d| [d.name, d]}]
    end

    def lock_dependencies
      @lock_dependencies ||= lock.dependencies
    end
    def lock_dependency_names
      @lock_dependency_names ||= Set.new(lock_dependencies.map{|d| d.name})
    end
    def lock_dependency_index
      @lock_dependency_index ||= Hash[lock_dependencies.map{|d| [d.name, d]}]
    end

    def lock_manifests
      @lock_manifests ||= lock.manifests
    end
    def lock_manifests_index
      @lock_manifests_index ||= ManifestSet.new(lock_manifests).to_hash
    end

    def removed_dependency_names
      @removed_dependency_names ||= lock_dependency_names - spec_dependency_names
    end

    # A dependency which is deleted from the specfile will, in the general case,
    #   be removed conservatively. This means it might not actually be removed.
    #   But if the dependency originally declared a source which is now non-
    #   default, it must be removed, even if another dependency has a transitive
    #   dependency on the one that was removed (which is the scenario in which
    #   a conservative removal would not remove it). In this case, we must also
    #   remove it explicitly so that it can be re-resolved from the default
    #   source.
    def explicit_removed_dependency_names
      @explicit_removed_dependency_names ||= removed_dependency_names.reject do |name|
        lock_manifest = lock_manifests_index[name]
        lock_manifest.source == spec.source
      end.to_set
    end

    def added_dependency_names
      @added_dependency_names ||= spec_dependency_names - lock_dependency_names
    end

    def nonmatching_added_dependency_names
      @nonmatching_added_dependency_names ||= added_dependency_names.reject do |name|
        spec_dependency = spec_dependency_index[name]
        lock_manifest = lock_manifests_index[name]
        if lock_manifest
          matching = true
          matching &&= spec_dependency.satisfied_by?(lock_manifest)
          matching &&= spec_dependency.source == lock_manifest.source
          matching
        else
          false
        end
      end.to_set
    end

    def common_dependency_names
      @common_dependency_names ||= lock_dependency_names & spec_dependency_names
    end

    def changed_dependency_names
      @changed_dependency_names ||= common_dependency_names.reject do |name|
        spec_dependency = spec_dependency_index[name]
        lock_dependency = lock_dependency_index[name]
        lock_manifest = lock_manifests_index[name]
        same = true
        same &&= spec_dependency.satisfied_by?(lock_manifest)
        same &&= spec_dependency.source == lock_dependency.source
        same
      end.to_set
    end

    def deep_keep_manifest_names
      @deep_keep_manifest_names ||= begin
        lock_dependency_names - (
          removed_dependency_names +
          changed_dependency_names +
          nonmatching_added_dependency_names
        )
      end
    end

    def shallow_strip_manifest_names
      @shallow_strip_manifest_names ||= begin
        explicit_removed_dependency_names + changed_dependency_names
      end
    end

    def inspect
      Helpers.strip_heredoc(<<-INSPECT)
        <##{self.class.name}:
          Removed: #{removed_dependency_names.to_a.join(", ")}
          ExplicitRemoved: #{explicit_removed_dependency_names.to_a.join(", ")}
          Added: #{added_dependency_names.to_a.join(", ")}
          NonMatchingAdded: #{nonmatching_added_dependency_names.to_a.join(", ")}
          Changed: #{changed_dependency_names.to_a.join(", ")}
          DeepKeep: #{deep_keep_manifest_names.to_a.join(", ")}
          ShallowStrip: #{shallow_strip_manifest_names.to_a.join(", ")}
        >
      INSPECT
    end

    # Returns an array of those manifests from the previous spec which should be kept,
    #   based on inspecting the new spec against the locked resolution from the previous spec.
    def analyze
      @analyze ||= begin
        debug { "Analyzing spec and lock:" }

        if same?
          debug { "  Same!" }
          return lock.manifests
        end

        debug { "  Removed:" } ; removed_dependency_names.each { |name| debug { "    #{name}" } }
        debug { "  ExplicitRemoved:" } ; explicit_removed_dependency_names.each { |name| debug { "    #{name}" } }
        debug { "  Added:" } ; added_dependency_names.each { |name| debug { "    #{name}" } }
        debug { "  NonMatchingAdded:" } ; nonmatching_added_dependency_names.each { |name| debug { "    #{name}" } }
        debug { "  Changed:" } ; changed_dependency_names.each { |name| debug { "    #{name}" } }
        debug { "  DeepKeep:" } ; deep_keep_manifest_names.each { |name| debug { "    #{name}" } }
        debug { "  ShallowStrip:" } ; shallow_strip_manifest_names.each { |name| debug { "    #{name}" } }

        manifests = ManifestSet.new(lock_manifests)
        manifests.deep_keep!(deep_keep_manifest_names)
        manifests.shallow_strip!(shallow_strip_manifest_names)
        manifests.to_a
      end
    end

  private

    def debug(*args, &block)
      environment.logger.debug(*args, &block)
    end

  end
end

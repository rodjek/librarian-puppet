module Librarian
  #
  # Represents the output of the resolution process. Captures the declared
  # dependencies plus the full set of resolved manifests. The sources are
  # already known by the dependencies and by the resolved manifests, so they do
  # not need to be captured explicitly.
  #
  # This representation may be produced by the resolver, may be serialized into
  # a lockfile, and may be deserialized from a lockfile. It is expected that the
  # lockfile is a direct representation in text of this representation, so that
  # the serialization-deserialization process is just the identity function.
  #
  class Resolution
    attr_reader :dependencies, :manifests, :manifests_index

    def initialize(dependencies, manifests)
      @dependencies, @manifests = dependencies, manifests
      @manifests_index = build_manifests_index(manifests)
    end

    def correct?
      manifests && manifests_consistent_with_dependencies? && manifests_internally_consistent?
    end

    def sources
      manifests.map{|m| m.source}.uniq
    end

  private

    def build_manifests_index(manifests)
      Hash[manifests.map{|m| [m.name, m]}] if manifests
    end

    def manifests_consistent_with_dependencies?
      ManifestSet.new(manifests).in_compliance_with?(dependencies)
    end

    def manifests_internally_consistent?
      ManifestSet.new(manifests).consistent?
    end

  end
end

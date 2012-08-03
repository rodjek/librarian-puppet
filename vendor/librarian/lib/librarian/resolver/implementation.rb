require 'librarian/dependency'

module Librarian
  class Resolver
    class Implementation

      attr_reader :resolver, :source, :dependency_source_map

      def initialize(resolver, spec)
        @resolver = resolver
        @source = spec.source
        @dependency_source_map = Hash[spec.dependencies.map{|d| [d.name, d.source]}]
        @level = 0
      end

      def resolve(dependencies, manifests = {})
        dependencies += manifests.values.map { |m|
          m.dependencies.map { |d| sourced_dependency_for(d) }
        }.flatten(1)
        resolution = recursive_resolve([], manifests, dependencies)
        resolution ? resolution[1] : nil
      end

      def sourced_dependency_for(dependency)
        return dependency if dependency.source

        s = dependency_source_map[dependency.name] || source
        Dependency.new(dependency.name, dependency.requirement, s)
      end

      def recursive_resolve(dependencies, manifests, queue)
        if dependencies.empty?
          queue.each do |dependency|
            debug { "Scheduling #{dependency}" }
          end
        end
        failure = false
        until failure || queue.empty?
          dependency = queue.shift
          dependencies << dependency
          debug { "Resolving #{dependency}" }
          scope do
            if manifests.key?(dependency.name)
              unless dependency.satisfied_by?(manifests[dependency.name])
                debug { "Conflicts with #{manifests[dependency.name]}" }
                failure = true
              else
                debug { "Accords with all prior constraints" }
                # nothing left to do
              end
            else
              debug { "No known prior constraints" }
              resolution = nil
              related_dependencies = dependencies.select{|d| d.name == dependency.name}
              unless dependency.manifests && dependency.manifests.first
                debug { "No known manifests" }
              else
                debug { "Checking manifests" }
                scope do
                  dependency.manifests.each do |manifest|
                    break if resolution

                    debug { "Checking #{manifest}" }
                    scope do
                      if related_dependencies.all?{|d| d.satisfied_by?(manifest)}
                        m = manifests.merge(dependency.name => manifest)
                        a = manifest.dependencies.map { |d| sourced_dependency_for(d) }
                        a.each do |d|
                          debug { "Scheduling #{d}" }
                        end
                        q = queue + a
                        resolution = recursive_resolve(dependencies.dup, m, q)
                      end
                      if resolution
                        debug { "Resolved #{dependency} at #{manifest}" }
                      else
                        debug { "Backtracking from #{manifest}" }
                      end
                    end
                  end
                end
                if resolution
                  debug { "Resolved #{dependency}" }
                else
                  debug { "Failed to resolve #{dependency}" }
                end
              end
              unless resolution
                failure = true
              else
                dependencies, manifests, queue = *resolution
              end
            end
          end
        end
        failure ? nil : [dependencies, manifests, queue]
      end

    private

      def scope
        @level += 1
        yield
      ensure
        @level -= 1
      end

      def debug
        environment.logger.debug { '  ' * @level + yield }
      end

      def environment
        resolver.environment
      end

    end
  end
end

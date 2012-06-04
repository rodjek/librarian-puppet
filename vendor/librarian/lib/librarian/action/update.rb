require "librarian/error"
require "librarian/manifest_set"
require "librarian/resolver"
require "librarian/spec_change_set"
require "librarian/action/base"

module Librarian
  module Action
    class Update < Base

      def run
        unless lockfile_path.exist?
          raise Error, "Lockfile missing!"
        end
        previous_resolution = lockfile.load(lockfile_path.read)
        spec = specfile.read(previous_resolution.sources)
        changes = spec_change_set(spec, previous_resolution)
        manifests = changes.same? ? previous_resolution.manifests : changes.analyze
        partial_manifests = ManifestSet.deep_strip(manifests, dependency_names)
        unpinnable_sources = previous_resolution.sources - partial_manifests.map(&:source)
        unpinnable_sources.each(&:unpin!)
        resolution = resolver.resolve(spec, partial_manifests)
        unless resolution.correct?
          raise Error, "Could not resolve the dependencies."
        else
          lockfile_text = lockfile.save(resolution)
          debug { "Bouncing #{lockfile_name}" }
          bounced_lockfile_text = lockfile.save(lockfile.load(lockfile_text))
          unless bounced_lockfile_text == lockfile_text
            debug { "lockfile_text: \n#{lockfile_text}"}
            debug { "bounced_lockfile_text: \n#{bounced_lockfile_text}"}
            raise Error, "Cannot bounce #{lockfile_name}!"
          end
          lockfile_path.open('wb') { |f| f.write(lockfile_text) }
        end
      end

    private

      def dependency_names
        options[:names]
      end

      def specfile_name
        environment.specfile_name
      end

      def lockfile_name
        environment.lockfile_name
      end

      def specfile_path
        environment.specfile_path
      end

      def lockfile_path
        environment.lockfile_path
      end

      def specfile
        environment.specfile
      end

      def lockfile
        environment.lockfile
      end

      def resolver
        Resolver.new(environment)
      end

      def spec_change_set(spec, lock)
        SpecChangeSet.new(environment, spec, lock)
      end

    end
  end
end

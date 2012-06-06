require "librarian/manifest_set"
require "librarian/spec_change_set"
require "librarian/action/base"

module Librarian
  module Action
    class Install < Base

      def run
        check_preconditions

        perform_installation
      end

    private

      def check_preconditions
        check_specfile
        check_lockfile
        check_consistent
      end

      def check_specfile
        raise Error, "#{specfile_name} missing!" unless specfile_path.exist?
      end

      def check_lockfile
        raise Error, "#{lockfile_name} missing!" unless lockfile_path.exist?
      end

      def check_consistent
        raise Error, "#{specfile_name} and #{lockfile_name} are out of sync!" unless spec_consistent_with_lock?
      end

      def perform_installation
        manifests = sorted_manifests

        create_install_path
        install_manifests(manifests)
      end

      def create_install_path
        install_path.rmtree if install_path.exist?
        install_path.mkpath
      end

      def install_manifests(manifests)
        manifests.each do |manifest|
          manifest.install!
        end
      end

      def sorted_manifests
        ManifestSet.sort(lock.manifests)
      end

      def specfile_name
        environment.specfile_name
      end

      def specfile_path
        environment.specfile_path
      end

      def lockfile_name
        environment.lockfile_name
      end

      def lockfile_path
        environment.lockfile_path
      end

      def spec
        environment.spec
      end

      def lock
        environment.lock
      end

      def spec_change_set(spec, lock)
        SpecChangeSet.new(environment, spec, lock)
      end

      def spec_consistent_with_lock?
        spec_change_set(spec, lock).same?
      end

      def install_path
        environment.install_path
      end

    end
  end
end

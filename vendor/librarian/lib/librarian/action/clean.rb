require "librarian/action/base"

module Librarian
  module Action
    class Clean < Base

      def run
        clean_cache_path
        clean_install_path
      end

    private

      def clean_cache_path
        if cache_path.exist?
          debug { "Deleting #{project_relative_path_to(cache_path)}" }
          cache_path.rmtree
        end
      end

      def clean_install_path
        if install_path.exist?
          install_path.children.each do |c|
            debug { "Deleting #{project_relative_path_to(c)}" }
            c.rmtree unless c.file?
          end
        end
      end

      def cache_path
        environment.cache_path
      end

      def install_path
        environment.install_path
      end

      def project_relative_path_to(path)
        environment.project_relative_path_to(path)
      end

    end
  end
end

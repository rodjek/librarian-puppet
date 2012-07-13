require 'librarian/support/abstract_method'

module Librarian
  module Source
    # Requires that the including source class have methods:
    #   #path
    #   #environment
    module Local

      include Support::AbstractMethod

      abstract_method :path, :fetch_version, :fetch_dependencies

      def manifests(name)
        manifest = Manifest.new(self, name)
        [manifest].compact
      end

      def manifest(name, version, dependencies)
        manifest = Manifest.new(self, name)
        manifest.version = version
        manifest.dependencies = dependencies
        manifest
      end

      def manifest_search_paths(name)
        @manifest_search_paths ||= { }
        @manifest_search_paths[name] ||= begin
          cache!
          paths = [filesystem_path, filesystem_path.join(name)]
          paths.select{|s| s.exist?}
        end
      end

      def found_path(name)
        @_found_paths ||= { }
        @_found_paths[name] ||= begin
          paths = manifest_search_paths(name)
          paths.find{|p| manifest?(name, p)}
        end
      end

    private

      abstract_method :manifest? # (name, path) -> boolean

      def info(*args, &block)
        environment.logger.info(*args, &block)
      end

      def debug(*args, &block)
        environment.logger.debug(*args, &block)
      end

      def relative_path_to(path)
        environment.logger.relative_path_to(path)
      end

    end
  end
end

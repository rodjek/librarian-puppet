# parent class for githubtarball and forge source Repos
module Librarian
  module Puppet
    module Source
      class Repo

        attr_accessor :source, :name
        private :source=, :name=

        def initialize(source, name)
          self.source = source
          self.name = name
        end

        def environment
          source.environment
        end

        def cache_path
          @cache_path ||= source.cache_path.join(name)
        end

        def version_unpacked_cache_path(version)
          cache_path.join(version.to_s)
        end

        def vendored?(name, version)
          vendored_path(name, version).exist?
        end

        def vendored_path(name, version)
          environment.vendor_cache.join("#{name}-#{version}.tar.gz")
        end

      end
    end
  end
end

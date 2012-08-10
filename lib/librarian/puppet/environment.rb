require "librarian/environment"
require "librarian/puppet/dsl"
require "librarian/puppet/source"
require "librarian/puppet/lockfile/parser"

module Librarian
  module Puppet
    class Environment < Librarian::Environment

      def adapter_name
        "puppet"
      end

      def install_path
        part = config_db["path"] || "modules"
        project_path.join(part)
      end

      def vendor_cache
        project_path.join('vendor/puppet/cache')
      end

      def cache_path
        project_path.join(".tmp/librarian/cache")
      end

      def scratch_path
        project_path.join(".tmp/librarian/scratch")
      end

      def vendor_packages?
        vendor_cache.exist?
      end
    end
  end
end

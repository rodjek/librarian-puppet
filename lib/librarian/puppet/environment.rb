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

      def cache_path
        project_path.join(".tmp/librarian/cache")
      end

      def scratch_path
        project_path.join(".tmp/librarian/scratch")
      end
    end
  end
end

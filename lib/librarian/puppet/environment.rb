require "librarian/environment"
require "librarian/puppet/dsl"
require "librarian/puppet/source"

module Librarian
  module Puppet
    class Environment < Librarian::Environment

      def adapter_name
        "puppet"
      end

      def install_path
        project_path.join("modules")
      end
    end
  end
end

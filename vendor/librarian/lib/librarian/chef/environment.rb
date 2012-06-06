require "librarian/environment"
require "librarian/chef/dsl"
require "librarian/chef/source"

module Librarian
  module Chef
    class Environment < Environment

      def adapter_name
        "chef"
      end

      def install_path
        project_path.join("cookbooks")
      end

    end
  end
end

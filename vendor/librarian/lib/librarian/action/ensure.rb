require "librarian/error"
require "librarian/action/base"

module Librarian
  module Action
    class Ensure < Base

      def run
        raise Error, "Cannot find #{specfile_name}!" unless project_path
      end

    private

      def specfile_name
        environment.specfile_name
      end

      def project_path
        environment.project_path
      end

    end
  end
end

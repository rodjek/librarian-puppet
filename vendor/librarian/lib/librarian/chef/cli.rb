require 'librarian/helpers'

require 'librarian/cli'
require 'librarian/chef'

module Librarian
  module Chef
    class Cli < Librarian::Cli

      module Particularity
        def root_module
          Chef
        end
      end

      include Particularity
      extend Particularity

      source_root Pathname.new(__FILE__).dirname.join("templates")

      def init
        copy_file environment.specfile_name
      end

    end
  end
end

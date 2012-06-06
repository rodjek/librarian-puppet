require 'librarian/cli'
require 'librarian/mock'

module Librarian
  module Mock
    class Cli < Librarian::Cli

      module Particularity
        def root_module
          Mock
        end
      end

      include Particularity
      extend Particularity

    end
  end
end

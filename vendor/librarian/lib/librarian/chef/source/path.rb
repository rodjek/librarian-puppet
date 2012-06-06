require 'librarian/source/path'
require 'librarian/chef/source/local'

module Librarian
  module Chef
    module Source
      class Path < Librarian::Source::Path
        include Local
      end
    end
  end
end

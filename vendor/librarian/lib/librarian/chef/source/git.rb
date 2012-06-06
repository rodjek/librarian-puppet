require 'librarian/source/git'
require 'librarian/chef/source/local'

module Librarian
  module Chef
    module Source
      class Git < Librarian::Source::Git
        include Local
      end
    end
  end
end

require 'librarian/source/path'
require 'librarian/puppet/source/local'

module Librarian
  module Puppet
    module Source
      class Path < Librarian::Source::Path
        include Local
      end
    end
  end
end

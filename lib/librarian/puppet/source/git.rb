require 'librarian/source/git'
require 'librarian/puppet/source/local'

module Librarian
  module Puppet
    module Source
      class Git < Librarian::Source::Git
        include Local
      end
    end
  end
end

require 'librarian/dsl'
require 'librarian/puppet/source'

module Librarian
  module Puppet
    class Dsl < Librarian::Dsl

      dependency :mod

      source :git => Source::Git
      source :path => Source::Path
    end
  end
end

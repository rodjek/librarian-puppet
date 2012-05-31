require 'librarian/helpers'

require 'librarian/cli'
require 'librarian/puppet'

module Librarian
  module Puppet
    class Cli < Librarian::Cli

      module Particularity
        def root_module
          Puppet
        end
      end

      include Particularity
      extend Particularity

      source_root Pathname.new(__FILE__).dirname.join("templates")

      def init
        copy_file environment.specfile_name
      end

      def version
        say "librarian-puppet v#{Librarian::Puppet::VERSION}"
      end
    end
  end
end

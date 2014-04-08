require 'librarian'
require 'fileutils'

require 'librarian/puppet/extension'
require 'librarian/puppet/version'

require 'librarian/action/install'

module Librarian
  module Puppet
    def puppet_version
      out = nil
      begin
        out = Librarian::Posix.run!(%W{puppet --version})
      rescue Librarian::Posix::CommandFailure => error

        $stderr.puts <<-EOF
      Unable to load puppet. Please install it using native packages for your platform (eg .deb, .rpm, .dmg, etc).
      puppet --version returned #{error.status}
      #{error.message unless error.message.nil?}
      EOF
        exit 1
      end
      out.split(' ').first.strip
    end
  end
end

PUPPET_VERSION=Librarian::Puppet::puppet_version

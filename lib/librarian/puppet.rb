require 'librarian'
require 'fileutils'

out = nil
begin
  out = Librarian::Posix.run!(%W{puppet --version})
rescue Librarian::Posix::CommandFailure => error

  $stderr.puts <<-EOF
Unable to load puppet. Please install it using native packages for your platform (eg .deb, .rpm, .dmg, etc).
puppet --version returned #{status.exitstatus}
#{error.message unless error.message.nil?}
EOF
  exit 1
end

PUPPET_VERSION=out.split(' ').first.strip

require 'librarian/puppet/extension'
require 'librarian/puppet/version'

require 'librarian/action/install'

module Librarian
  module Puppet
  end
end

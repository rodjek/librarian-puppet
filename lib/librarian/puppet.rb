require 'librarian'
require 'fileutils'

begin
  require 'puppet'
rescue LoadError
  $stderr.puts <<-EOF
Unable to load puppet. Either install it using native packages for your
platform (eg .deb, .rpm, .dmg, etc) or as a gem (gem install puppet).
EOF
  exit 1
end

require 'librarian/puppet/extension'
require 'librarian/puppet/version'

require 'librarian/action/install'

module Librarian
  module Puppet
  end
end

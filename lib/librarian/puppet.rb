require 'librarian'
require 'fileutils'
require 'open3'

status = nil
puppet_version = nil

begin
  Open3.popen3('puppet --version') {|stdin, stdout, stderr, wait_thr|
    pid = wait_thr.pid # pid of the started process.
    puppet_version = stdout.read
    status = wait_thr.value # Process::Status object returned.
  }
rescue
end

if status.nil? or status.exitstatus != 0
  $stderr.puts <<-EOF
Unable to load puppet. Please install it using native packages for your platform (eg .deb, .rpm, .dmg, etc).
EOF
  exit 1
end

PUPPET_VERSION=puppet_version.split(' ').first.strip

require 'librarian/puppet/extension'
require 'librarian/puppet/version'

require 'librarian/action/install'

module Librarian
  module Puppet
  end
end

require 'librarian'
require 'fileutils'
require 'open3'

# require open3_backport in ruby 1.8 and install if not present
# https://github.com/rodjek/librarian-puppet/issues/167
if RUBY_VERSION < '1.9'
  begin
    require 'open3_backport'
  rescue LoadError
    require 'rubygems/dependency_installer.rb'
    Gem::DependencyInstaller.new.install 'open3_backport'
    require 'open3_backport'
  end
end

status = nil
out = nil
error = nil

begin
  Open3.popen3('puppet --version') {|stdin, stdout, stderr, wait_thr|
    pid = wait_thr.pid # pid of the started process.
    out = stdout.read
    status = wait_thr.value # Process::Status object returned.
  }
rescue => e
  error = e
end

if status.nil? or status.exitstatus != 0
  $stderr.puts <<-EOF
Unable to load puppet. Please install it using native packages for your platform (eg .deb, .rpm, .dmg, etc).
#{out.nil? or out.empty? ? "puppet --version returned #{status.exitstatus}" : out}
#{error.message unless error.nil?}
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

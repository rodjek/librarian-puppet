require 'librarian'
require 'fileutils'
require 'open3'
require 'open3_backport' if RUBY_VERSION < '1.9'

status = nil
out = nil
err = nil
error = nil

begin
  if RUBY_VERSION < '1.9'
    # Ruby 1.8.x backport of popen3 doesn't allow the 'env' hash argument
    # Not sanitizing the environment for the moment.
    Open3.popen3('puppet --version') { |stdin, stdout, stderr, wait_thr|
      pid = wait_thr.pid # pid of the started process.
      out = stdout.read
      err = stderr.read
      status = wait_thr.value # Process::Status object returned.
    }
  else
		env_reset = {'BUNDLE_APP_CONFIG' => nil, 'BUNDLE_CONFIG' => nil, 'BUNDLE_GEMFILE' => nil, 'BUNDLE_BIN_PATH' => nil,
								 'RUBYLIB' => nil, 'RUBYOPT' => nil, 'GEMRC' => nil, 'GEM_PATH' => nil}
    Open3.popen3(env_reset, 'puppet --version') { |stdin, stdout, stderr, wait_thr|
      pid = wait_thr.pid # pid of the started process.
      out = stdout.read
      err = stderr.read
      status = wait_thr.value # Process::Status object returned.
    }
  end
rescue => e
  error = e
end

if status.nil? or status.exitstatus != 0
  $stderr.puts <<-EOF
Unable to load puppet. Please install it using native packages for your platform (eg .deb, .rpm, .dmg, etc).
#{out.nil? or out.empty? ? "puppet --version returned #{status.exitstatus}" : out}
#{error.message unless error.nil?}
#{err unless err.nil?}
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

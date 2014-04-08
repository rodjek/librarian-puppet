require 'librarian'
require 'fileutils'

require 'librarian/puppet/extension'
require 'librarian/puppet/version'

require 'librarian/action/install'

module Librarian
  module Puppet
    @@puppet_version = nil

    def puppet_version
      return @@puppet_version unless @@puppet_version.nil?

      begin
        @@puppet_version = Librarian::Posix.run!(%W{puppet --version})
      rescue Librarian::Posix::CommandFailure => error
        msg = "Unable to load puppet. Please install it using native packages for your platform (eg .deb, .rpm, .dmg, etc)."
        msg += "\npuppet --version returned #{error.status}"
        msg += "\n#{error.message}" unless error.message.nil?
        $stderr.puts msg
        exit 1
      end
      return @@puppet_version
    end

    def puppet_gem_version
      Gem::Version.create(puppet_version.split(' ').first.strip.gsub('-', '.'))
    end

  end
end

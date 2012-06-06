require 'pathname'
require 'securerandom'
require 'highline'

require 'librarian'
require 'librarian/action/install'
require 'librarian/chef'

module Librarian
  module Chef

    class Environment
      def install_path
        @install_path ||= begin
          has_home = ENV["HOME"] && File.directory?(ENV["HOME"])
          tmp_dir = Pathname.new(has_home ? "~/.librarian/tmp" : "/tmp/librarian").expand_path
          enclosing = tmp_dir.join("chef/integration/knife/install")
          enclosing.mkpath unless enclosing.exist?
          dir = enclosing.join(SecureRandom.hex(16))
          dir.mkpath
          at_exit { dir.rmtree }
          dir
        end
      end
    end

    def install_path
      environment.install_path
    end

    hl = HighLine.new

    begin
      Action::Install.new(environment).run
    rescue Error => e
      message = hl.color(e.message, HighLine::RED)
      hl.say(message)
      Process.exit!(1)
    end

  end
end

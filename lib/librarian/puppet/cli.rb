require 'librarian/helpers'

require 'librarian/cli'
require 'librarian/puppet'
require 'librarian/puppet/action'

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

        if File.exists? ".gitignore"
          gitignore = File.read('.gitignore').split("\n")
        else
          gitignore = []
        end

        gitignore << ".tmp/" unless gitignore.include? ".tmp/"
        gitignore << "modules/" unless gitignore.include? "modules/"

        File.open(".gitignore", 'w') do |f|
          f.puts gitignore.join("\n")
        end
      end

      desc "install", "Resolves and installs all of the dependencies you specify."
      option "quiet", :type => :boolean, :default => false
      option "verbose", :type => :boolean, :default => false
      option "line-numbers", :type => :boolean, :default => false
      option "clean", :type => :boolean, :default => false
      option "strip-dot-git", :type => :boolean
      option "path", :type => :string
      option "destructive", :type => :boolean, :default => false
      option "local", :type => :boolean, :default => false
      option "use-v1-api", :type => :boolean, :default => true
      def install

        ensure!
        clean! if options["clean"]
        unless options["destructive"].nil?
          environment.config_db.local['destructive'] = options['destructive'].to_s
        end
        if options.include?("strip-dot-git")
          strip_dot_git_val = options["strip-dot-git"] ? "1" : nil
          environment.config_db.local["install.strip-dot-git"] = strip_dot_git_val
        end
        if options.include?("path")
          environment.config_db.local["path"] = options["path"]
        end

        environment.config_db.local['use-v1-api'] = options['use-v1-api'] ? '1' : nil
        environment.config_db.local['mode'] = options['local'] ? 'local' : nil

        resolve!
        debug { "Install: dependencies resolved"}
        install!
      end

      desc "package", "Cache the puppet modules in vendor/puppet/cache."
      option "quiet", :type => :boolean, :default => false
      option "verbose", :type => :boolean, :default => false
      option "line-numbers", :type => :boolean, :default => false
      option "clean", :type => :boolean, :default => false
      option "strip-dot-git", :type => :boolean
      option "path", :type => :string
      option "destructive", :type => :boolean, :default => false
      def package
        environment.vendor!
        install
      end

      def version
        say "librarian-puppet v#{Librarian::Puppet::VERSION}"
      end

      private

      # override the actions to use our own

      def install!(options = { })
        Action::Install.new(environment, options).run
      end
    end
  end
end

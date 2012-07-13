require 'thor'
require 'thor/actions'

require 'librarian'
require 'librarian/error'
require 'librarian/action'
require "librarian/ui"

module Librarian
  class Cli < Thor

    autoload :ManifestPresenter, "librarian/cli/manifest_presenter"

    include Thor::Actions

    module Particularity
      def root_module
        nil
      end
    end

    include Particularity
    extend Particularity

    class << self
      def bin!
        begin
          environment = root_module.environment
          start
        rescue Librarian::Error => e
          environment.ui.error e.message
          environment.ui.debug e.backtrace.join("\n")
          exit (e.respond_to?(:status_code) ? e.status_code : 1)
        rescue Interrupt => e
          environment.ui.error "\nQuitting..."
          exit 1
        end
      end
    end

    def initialize(*)
      super
      the_shell = (options["no-color"] ? Thor::Shell::Basic.new : shell)
      environment.ui = UI::Shell.new(the_shell)
      environment.ui.be_quiet! if options["quiet"]
      environment.ui.debug! if options["verbose"]
      environment.ui.debug_line_numbers! if options["verbose"] && options["line-numbers"]

      write_debug_header
    end

    desc "version", "Displays the version."
    def version
      say "librarian-#{root_module.version}"
    end

    desc "config", "Show or edit the config."
    option "verbose", :type => :boolean, :default => false
    option "line-numbers", :type => :boolean, :default => false
    option "global", :type => :boolean, :default => false
    option "local", :type => :boolean, :default => false
    option "delete", :type => :boolean, :default => false
    def config(key = nil, value = nil)
      if key
        raise Error, "cannot set both value and delete" if value && options["delete"]
        if options["delete"]
          raise Error, "must set either global or local" unless options["global"] ^ options["local"]
          scope = options["global"] ? :global : options["local"] ? :local : nil
          environment.config_db[key, scope] = nil
        elsif value
          raise Error, "must set either global or local" unless options["global"] ^ options["local"]
          scope = options["global"] ? :global : options["local"] ? :local : nil
          environment.config_db[key, scope] = value
        else
          raise Error, "cannot set both global and local" if options["global"] && options["local"]
          scope = options["global"] ? :global : options["local"] ? :local : nil
          if value = environment.config_db[key, scope]
            prefix = scope ? "#{key} (#{scope})" : key
            say "#{prefix}: #{value}"
          end
        end
      else
        environment.config_db.keys.each do |key|
          say "#{key}: #{environment.config_db[key]}"
        end
      end
    end

    desc "clean", "Cleans out the cache and install paths."
    option "verbose", :type => :boolean, :default => false
    option "line-numbers", :type => :boolean, :default => false
    def clean
      ensure!
      clean!
    end

    desc "update", "Updates and installs the dependencies you specify."
    option "verbose", :type => :boolean, :default => false
    option "line-numbers", :type => :boolean, :default => false
    def update(*names)
      ensure!
      if names.empty?
        resolve!(:force => true)
      else
        update!(:names => names)
      end
      install!
    end

    desc "outdated", "Lists outdated dependencies."
    option "verbose", :type => :boolean, :default => false
    option "line-numbers", :type => :boolean, :default => false
    def outdated
      ensure!
      resolution = environment.lock
      resolution.manifests.sort_by(&:name).each do |manifest|
        source = manifest.source
        source_manifest = source.manifests(manifest.name).first
        next if manifest.version == source_manifest.version
        say "#{manifest.name} (#{manifest.version} -> #{source_manifest.version})"
      end
    end

    desc "show", "Shows dependencies"
    option "verbose", :type => :boolean, :default => false
    option "line-numbers", :type => :boolean, :default => false
    option "detailed", :type => :boolean
    def show(*names)
      ensure!
      if environment.lockfile_path.file?
        manifest_presenter.present(names, :detailed => options["detailed"])
      else
        raise Error, "Be sure to install first!"
      end
    end

    desc "init", "Initializes the current directory."
    def init
      puts "Nothing to do."
    end

  private

    def environment
      root_module.environment
    end

    def ensure!(options = { })
      Action::Ensure.new(environment, options).run
    end

    def clean!(options = { })
      Action::Clean.new(environment, options).run
    end

    def install!(options = { })
      Action::Install.new(environment, options).run
    end

    def resolve!(options = { })
      Action::Resolve.new(environment, options).run
    end

    def update!(options = { })
      Action::Update.new(environment, options).run
    end

    def manifest_presenter
      ManifestPresenter.new(self, environment.lock.manifests)
    end

    def write_debug_header
      debug { "Ruby Version: #{RUBY_VERSION}" }
      debug { "Ruby Platform: #{RUBY_PLATFORM}" }
      debug { "Rubinius Version: #{Rubinius::VERSION}" } if defined?(Rubinius)
      debug { "JRuby Version: #{JRUBY_VERSION}" } if defined?(JRUBY_VERSION)
      debug { "Rubygems Version: #{Gem::VERSION}" }
      debug { "Librarian Version: #{VERSION}" }
      debug { "Librarian Adapter: #{environment.adapter_name}"}
      debug { "Project: #{environment.project_path}" }
      debug { "Specfile: #{relative_path_to(environment.specfile_path)}" }
      debug { "Lockfile: #{relative_path_to(environment.lockfile_path)}" }
      debug { "Git: #{Source::Git::Repository.bin}" }
      debug { "Git Version: #{Source::Git::Repository.new(environment, environment.project_path).version(:silent => true)}" }
      debug { "Git Environment Variables:" }
      git_env = ENV.to_a.select{|(k, v)| k =~ /\AGIT/}.sort_by{|(k, v)| k}
      if git_env.empty?
        debug { "  (empty)" }
      else
        git_env.each do |(k, v)|
          debug { "  #{k}=#{v}"}
        end
      end
    end

    def debug(*args, &block)
      environment.logger.debug(*args, &block)
    end

    def relative_path_to(path)
      environment.logger.relative_path_to(path)
    end

  end
end

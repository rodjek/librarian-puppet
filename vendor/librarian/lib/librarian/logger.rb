module Librarian
  class Logger

    librarian_path = Pathname(__FILE__)
    librarian_path = librarian_path.dirname until librarian_path.join("lib").directory?
    LIBRARIAN_PATH = librarian_path

    attr_accessor :environment
    private :environment=

    def initialize(environment)
      self.environment = environment
    end

    def info(string = nil, &block)
      return unless ui

      ui.info(string || yield)
    end

    def debug(string = nil, &block)
      return unless ui

      if ui.respond_to?(:debug_line_numbers) && ui.debug_line_numbers
        loc = caller.find{|l| !(l =~ /in `debug'$/)}
        if loc =~ /^(.+):(\d+):in `(.+)'$/
          loc = "#{Pathname.new($1).relative_path_from(LIBRARIAN_PATH)}:#{$2}:in `#{$3}'"
        end
        ui.debug { "[Librarian] #{string || yield} [#{loc}]" }
      else
        ui.debug { "[Librarian] #{string || yield}" }
      end
    end

    def relative_path_to(path)
      environment.project_relative_path_to(path)
    end

    private

    def ui
      environment.ui
    end

  end
end

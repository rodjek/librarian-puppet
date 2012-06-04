require 'librarian/support/abstract_method'

module Librarian
  module Helpers
    module Debug

      include Support::AbstractMethod

      LIBRARIAN_PATH = Pathname.new('../../../../').expand_path(__FILE__)

      abstract_method :environment

    private

      def relative_path_to(path)
        environment.project_relative_path_to(path)
      end

      def debug
        if ui = environment.ui
          if ui.respond_to? :debug_line_numbers and ui.debug_line_numbers
            loc = caller.find{|l| !(l =~ /in `debug'$/)}
            if loc =~ /^(.+):(\d+):in `(.+)'$/
              loc = "#{Pathname.new($1).relative_path_from(LIBRARIAN_PATH)}:#{$2}:in `#{$3}'"
            end
            ui.debug { "[Librarian] #{yield} [#{loc}]" }
          else
            ui.debug { "[Librarian] #{yield}" }
          end
        end
      end

    end
  end
end

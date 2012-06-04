require 'rubygems/user_interaction'

module Librarian
  class UI
    def warn(message = nil)
    end

    def debug(message = nil)
    end

    def error(message = nil)
    end

    def info(message = nil)
    end

    def confirm(message = nil)
    end

    class Shell < UI
      attr_writer :shell
      attr_reader :debug_line_numbers

      def initialize(shell)
        @shell = shell
        @quiet = false
        @debug = ENV['DEBUG']
        @debug_line_numbers = false
      end

      def debug(message = nil)
        @shell.say(message || yield) if @debug && !@quiet
      end

      def info(message = nil)
        @shell.say(message || yield) if !@quiet
      end

      def confirm(message = nil)
        @shell.say(message || yield, :green) if !@quiet
      end

      def warn(message = nil)
        @shell.say(message || yield, :yellow)
      end

      def error(message = nil)
        @shell.say(message || yield, :red)
      end

      def be_quiet!
        @quiet = true
      end

      def debug!
        @debug = true
      end

      def debug_line_numbers!
        @debug_line_numbers = true
      end
    end
  end
end
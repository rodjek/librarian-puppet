module Librarian
  module Helpers
    extend self

    # [active_support/core_ext/string/strip]
    def strip_heredoc(string)
      indent = string.scan(/^[ \t]*(?=\S)/).min
      indent = indent.respond_to?(:size) ? indent.size : 0
      string.gsub(/^[ \t]{#{indent}}/, '')
    end

  end
end

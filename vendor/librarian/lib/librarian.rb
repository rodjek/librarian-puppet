require 'librarian/version'
require 'librarian/environment'

module Librarian
  extend self

  def environment_class
    self::Environment
  end

  def environment
    @environment ||= environment_class.new
  end

  def version
    VERSION
  end

end

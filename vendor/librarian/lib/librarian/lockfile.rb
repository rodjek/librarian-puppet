require 'librarian/lockfile/compiler'
require 'librarian/lockfile/parser'

module Librarian
  class Lockfile

    attr_accessor :environment
    private :environment=
    attr_reader :path

    def initialize(environment, path)
      self.environment = environment
      @path = path
    end

    def save(resolution)
      Compiler.new(environment).compile(resolution)
    end

    def load(string)
      Parser.new(environment).parse(string)
    end

    def read
      load(path.read)
    end

  end
end

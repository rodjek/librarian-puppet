module Librarian
  class Spec

    attr_accessor :source, :dependencies
    private :source=, :dependencies=

    def initialize(source, dependencies)
      self.source = source
      self.dependencies = dependencies
    end

  end
end

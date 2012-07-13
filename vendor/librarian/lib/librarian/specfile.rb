module Librarian
  class Specfile

    attr_accessor :environment
    private :environment=
    attr_reader :path, :dependencies, :source

    def initialize(environment, path)
      self.environment = environment
      @path = path
    end

    def read(precache_sources = [])
      environment.dsl(path.read, precache_sources)
    end

  end
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "librarian/version"

Gem::Specification.new do |s|
  s.name        = "librarian"
  s.version     = Librarian::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jay Feldblum"]
  s.email       = ["y_feldblum@yahoo.com"]
  s.homepage    = ""
  s.summary     = %q{Librarian}
  s.description = %q{Librarian}

  s.rubyforge_project = "librarian"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "thor", "~> 0.15"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  s.add_development_dependency "webmock"
  s.add_development_dependency "fakefs"

  s.add_dependency "chef", ">= 0.10"
  s.add_dependency "highline"
  s.add_dependency "archive-tar-minitar", ">= 0.5.2"
end

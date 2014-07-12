$:.push File.expand_path("../lib", __FILE__)

require 'librarian/puppet/version'

Gem::Specification.new do |s|
  s.name = 'librarian-puppet'
  s.version = Librarian::Puppet::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Sharpe', 'Carlos Sanchez']
  s.license = 'MIT'
  s.email = ['tim@sharpe.id.au', 'carlos@apache.org']
  s.homepage = 'https://github.com/rodjek/librarian-puppet'
  s.summary = 'Bundler for your Puppet modules'
  s.description = 'Simplify deployment of your Puppet infrastructure by
  automatically pulling in modules from the forge and git repositories with
  a single command.'

  # puppet_forge gem requires ruby 1.9 so we do too, use version 1.0.x in ruby 1.8
  # s.required_ruby_version = '>= 1.9.0'

  s.files = [
    '.gitignore',
    'LICENSE',
    'README.md',
  ] + Dir['{bin,lib}/**/*']

  s.executables = ['librarian-puppet']

  s.add_dependency "librarian", ">=0.1.2"
  # s.add_dependency "puppet_forge"

  # only needed for ruby 1.8
  s.add_dependency "json"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  s.add_development_dependency "puppet", ENV["PUPPET_VERSION"]
  s.add_development_dependency "minitest", "~> 5"
  s.add_development_dependency "mocha"
end

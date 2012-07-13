$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../vendor/librarian/lib", __FILE__)
require 'librarian/puppet'

Gem::Specification.new do |s|
  s.name = 'librarian-puppet'
  s.version = Librarian::Puppet::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Sharpe']
  s.email = ['tim@sharpe.id.au']
  s.homepage = 'https://github.com/rodjek/librarian-puppet'
  s.summary = 'Bundler for your Puppet modules'
  s.description = 'Simplify deployment of your Puppet infrastructure by
  automatically pulling in modules from the forge and git repositories with
  a single command.'

  s.files = [
    '.gitignore',
    'LICENSE',
    'README.md',
  ] + Dir['{bin,lib,vendor}/**/*']

  s.executables = ['librarian-puppet']

  s.add_dependency "thor", "~> 0.15"
  s.add_dependency "json"
end

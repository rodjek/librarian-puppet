$:.push File.expand_path("../lib", __FILE__)
require 'librarian/puppet'

Gem::Specification.new do |s|
  s.name = 'librarian-puppet'
  s.version = Librarian::Puppet::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Sharpe']
  s.email = ['tim@sharpe.id.au']
  s.homepage = 'https://github.com/rodjek/librarian-puppet'
  s.summary = 'placeholder'
  s.description = 'another placeholder!'

  s.files = [
    'bin/librarian-puppet',
    'lib/librarian/puppet/cli.rb',
    'lib/librarian/puppet/dsl.rb',
    'lib/librarian/puppet/environment.rb',
    'lib/librarian/puppet/extension.rb',
    'lib/librarian/puppet/source/git.rb',
    'lib/librarian/puppet/source/local.rb',
    'lib/librarian/puppet/source/path.rb',
    'lib/librarian/puppet/source.rb',
    'lib/librarian/puppet/templates/Puppetfile',
    'lib/librarian/puppet.rb',
    'README.md',
  ]
  s.executables = ['librarian-puppet']

  s.add_dependency 'librarian'
end

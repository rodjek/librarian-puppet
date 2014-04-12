require 'bundler/setup'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include('pkg/', 'tmp/')
CLOBBER.include('Gemfile.lock')

RSpec::Core::RakeTask.new
Cucumber::Rake::Task.new(:features) do |t|
  # don't run githubtarball scenarios in Travis, they easily fail with rate limit exceeded
  t.cucumber_opts = "--tags ~@github" if ENV['TRAVIS']=='true'
end

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => [:test, :spec, :features]

desc "Bump version to the next minor"
task :bump do
  path = 'lib/librarian/puppet/version.rb'
  version_file = File.read(path)
  version = version_file.match(/VERSION = "(.*)"/)[1]
  v = Gem::Version.new("#{version}.0")
  new_version = v.bump.to_s
  version_file = version_file.gsub(/VERSION = ".*"/, "VERSION = \"#{new_version}\"")
  File.open(path, "w") {|file| file.puts version_file}
  sh "git add #{path}"
  sh "git commit -m \"Bump version to #{new_version}\""
end

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

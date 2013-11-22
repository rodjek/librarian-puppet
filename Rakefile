require 'bundlet/setup'
require 'cucumber/rake/task'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'
require 'bundler/gem_tasks'

CLEAN.include('pkg/', 'tmp/')
CLOBBER.include('Gemfile.lock')

Cucumber::Rake::Task.new(:features)

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => [:test, :features]

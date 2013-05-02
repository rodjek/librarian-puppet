require 'rake/clean'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

CLEAN.include('pkg/', 'tmp/')
CLOBBER.include('Gemfile.lock')

RSpec::Core::RakeTask.new
Cucumber::Rake::Task.new(:features)

task :default => [:spec, :features]

# Use our custom tag name
module Bundler
  class GemHelper
    def version_tag
      "maestrodev-v#{version}"
    end
  end
end

require 'bundler/gem_tasks'

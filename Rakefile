begin
  require 'rake/clean'
  require 'cucumber/rake/task'

  CLEAN.include('pkg/', 'tmp/')
  CLOBBER.include('Gemfile.lock')

  Cucumber::Rake::Task.new(:features)

  require 'bundler/gem_tasks'

  task :default => :features
rescue LoadError
end

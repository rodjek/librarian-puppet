begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  require 'bundler/gem_tasks'

  task :default => :features
rescue LoadError
end

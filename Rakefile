begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :default => :features
rescue LoadError
end

require 'bundler/gem_tasks'

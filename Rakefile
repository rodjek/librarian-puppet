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
  require 'puppet'
  puppet_version = Puppet::version.gsub("~>","").split(".").first.to_i
  tags = (2..4).select {|i| i != puppet_version}.map{|i| "--tags @puppet#{puppet_version},~@puppet#{i}"}
  # don't run githubtarball scenarios in Travis, they easily fail with rate limit exceeded
  tags << "--tags ~@github" if ENV['TRAVIS']=='true'
  t.cucumber_opts = tags.join(" ")
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

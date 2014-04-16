require 'aruba/cucumber'
require 'fileutils'

Before do
  @aruba_timeout_seconds = 120
end

Before('@spaces') do
  @dirs = ["tmp/aruba with spaces"]
  @dirs.each {|dir| FileUtils.rm_rf dir}
end

Given /^PENDING/ do
  pending
end

Given(/^there is no Puppetfile$/) do
  in_current_dir do
    fail "Puppetfile exists at #{File.expand_path('Puppetfile')}" if (File.exist?('Puppetfile'))
  end
end

ENV['LIBRARIAN_PUPPET_TMP'] = '.tmp'

require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 15
end

Before('@slow') do
  @aruba_timeout_seconds = 30
end

Before('@veryslow') do
  @aruba_timeout_seconds = 60
end

Before('@veryveryslow') do
  @aruba_timeout_seconds = 90
end

Given /^PENDING/ do |x|
  pending
end

Given(/^there is no Puppetfile$/) do
  in_current_dir do
    fail "Puppetfile exists at #{File.expand_path('Puppetfile')}" if (File.exist?('Puppetfile'))
  end
end

require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 15
end

Before('@slow') do
  @aruba_timeout_seconds = 25
end

Before('@veryslow') do
  @aruba_timeout_seconds = 50
end

Before('@veryveryslow') do
  @aruba_timeout_seconds = 90
end

Given /^PENDING/ do |x|
  pending
end

require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 10
end

Before('@slow') do
  @aruba_timeout_seconds = 20
end

Before('@veryslow') do
  @aruba_timeout_seconds = 50
end

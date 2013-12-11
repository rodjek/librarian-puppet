require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'

$LOAD_PATH << "vendor/librarian/lib"
require 'librarian/puppet'

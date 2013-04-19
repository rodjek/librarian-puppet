require 'rubygems'
require 'rspec'

vendor = File.expand_path('../../vendor/librarian/lib', __FILE__)
$:.unshift(vendor) unless $:.include?(vendor)

require 'librarian/puppet'

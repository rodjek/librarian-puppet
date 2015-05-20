require 'spec_helper'
require_relative '../../lib/librarian/puppet/action/resolve'
require 'librarian/ui'
require 'thor'

describe 'Librarian::Puppet::Action::Resolve' do

  let(:path) { File.expand_path("../../../features/examples/test", __FILE__) }
  let(:environment) { Librarian::Puppet::Environment.new(:project_path => path) }

  before do
    # run with DEBUG=true envvar to get debug output
    environment.ui = Librarian::UI::Shell.new(Thor::Shell::Basic.new)
  end

  describe '#run' do

    it 'should resolve dependencies' do
      Librarian::Puppet::Action::Resolve.new(environment, :force => true).run
      resolution = environment.lock.manifests.map { |m| {:name => m.name, :version => m.version.to_s, :source => m.source.to_s} }
      expect(resolution.size).to eq(1)
      expect(resolution.first[:name]).to eq("puppetlabs-stdlib")
      expect(resolution.first[:source]).to eq("https://forgeapi.puppetlabs.com")
      expect(resolution.first[:version]).to match(/\d+\.\d+\.\d+/)
    end

  end
end

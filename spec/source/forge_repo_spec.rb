require "librarian/puppet/source/forge"
require "librarian/puppet/environment"

describe Librarian::Puppet::Source::Forge::Repo do

  let(:environment) { Librarian::Puppet::Environment.new }
  let(:uri) { "https://forge.puppetlabs.com" }
  let(:source) { Librarian::Puppet::Source::Forge.new(environment, uri) }
  subject { Librarian::Puppet::Source::Forge::Repo.new(source, "puppetlabs/stdlib") }

  describe "#check_puppet_module_options" do
    context "Puppet OS" do
    end
  end
end

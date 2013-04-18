require 'spec_helper'

describe Librarian::Puppet::Requirement do

  it 'should handle .x versions' do
    described_class.new('1.x').gem_requirement.should eq('~> 1.0')
    described_class.new('1.0.x').gem_requirement.should eq('~> 1.0.0')
  end

  it 'should handle version ranges' do
    described_class.new('>=1.1.0 <2.0.0').gem_requirement.should eq(['>=1.1.0', '<2.0.0'])
  end

  it 'should print to_s' do
    described_class.new('1.x').to_s.should eq('~> 1.0')
    described_class.new('>=1.1.0 <2.0.0').to_s.should eq("[\">=1.1.0\", \"<2.0.0\"]")
  end
end

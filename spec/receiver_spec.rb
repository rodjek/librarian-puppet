require 'spec_helper'

describe 'Librarian::Puppet::Dsl::Receiver' do

  let(:dsl) { Librarian::Puppet::Dsl.new({}) }
  let(:target) { Librarian::Dsl::Target.new(dsl) }
  let(:receiver) { Librarian::Puppet::Dsl::Receiver.new(target) }
  let(:environment) { Librarian::Puppet::Environment.new(:project_path => '/tmp/tmp_module') }
  describe '#run' do

    it 'should get working_dir from pwd when specfile is nil' do
      receiver.run(nil) {}
      expect(receiver.working_path).to eq(Pathname.new(Dir.pwd))
    end

    it 'should get working_dir from pwd with default specfile' do
      receiver.run(dsl.default_specfile) {}
      expect(receiver.working_path).to eq(Pathname.new(Dir.pwd))
    end

    it 'should get working_dir from given path' do
      receiver.run(Pathname.new('/tmp/tmp_module/Puppetfile')) {}
      expect(receiver.working_path).to eq(Pathname.new('/tmp/tmp_module'))
    end

    it 'test receiver run' do
      error_message = 'Metadata file does not exist: '+File.join(environment.project_path, 'metadata.json')
      expect{environment.dsl(environment.specfile.path, [])}.to raise_error(Librarian::Error,error_message)
    end
  end
end

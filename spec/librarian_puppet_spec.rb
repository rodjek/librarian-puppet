describe Librarian::Puppet do
  it 'exits with error if puppet is not installed' do
    error = Librarian::Posix::CommandFailure.new 'puppet not installed'
    error.status = 42

    expect(Librarian::Posix).to receive(:run!).and_raise(error)
    expect($stderr).to receive(:puts) do |message|
      expect(message).to match /42/
      expect(message).to match /puppet not installed/
    end

    expect { Librarian::Puppet::puppet_version }.to raise_error(SystemExit)
  end
end

require File.expand_path("../../../../test_helper", __FILE__)
require "librarian/puppet/source/githubtarball"

describe Librarian::Puppet::Source::GitHubTarball::Repo do
  def assert_exact_error(klass, message)
    yield
  rescue Exception => e
    e.class.must_equal klass
    e.message.must_equal message
  else
    raise "No exception was raised!"
  end

  describe "#api_call" do
    let(:repo) { Librarian::Puppet::Source::GitHubTarball::Repo.new("foo", "bar") }
    let(:headers) { {'User-Agent' => "librarian-puppet v#{Librarian::Puppet::VERSION}"} }

    it "succeeds" do
      response = {"api" => "response"}
      repo.expects(:http_get).with('https://api.github.com/foo', {:headers => headers}).returns([200, JSON.dump(response)])
      repo.send(:api_call, "/foo").must_equal(response)
    end

    it "fails when we hit api limit" do
      response = {"message" => "Oh boy! API rate limit exceeded!!!"}
      repo.expects(:http_get).with('https://api.github.com/foo', {:headers => headers}).returns([403, JSON.dump(response)])
      message = "Oh boy! API rate limit exceeded!!! -- increase limit by authenticating via GITHUB_API_TOKEN=your-token"
      assert_exact_error Librarian::Error, message do
        repo.send(:api_call, "/foo")
      end
    end

    it "fails with unknown error message" do
      response = {}
      repo.expects(:http_get).with('https://api.github.com/foo', {:headers => headers}).returns([403, JSON.dump(response)])
      repo.send(:api_call, "/foo").must_equal nil
    end

    it "fails with html" do
      repo.expects(:http_get).with('https://api.github.com/foo', {:headers => headers}).returns([403, "<html>Oh boy!</html>"])
      repo.send(:api_call, "/foo").must_equal nil
    end

    it "fails with unknown code" do
      response = {}
      repo.expects(:http_get).with('https://api.github.com/foo', {:headers => headers}).returns([500, JSON.dump(response)])
      repo.send(:api_call, "/foo").must_equal nil
    end
  end
end

require "fileutils"
require "pathname"
require "securerandom"

require "librarian/source/git/repository"

describe Librarian::Source::Git::Repository do

  let(:env) do
    double(:ui => nil, :logger => double(:debug => nil, :info => nil))
  end

  let(:project_path) do
    project_path = Pathname.new(__FILE__).expand_path
    project_path = project_path.dirname until project_path.join("Rakefile").exist?
    project_path
  end
  let(:tmp_path) { project_path + "tmp/spec/unit/source/git/repository-spec" }
  let(:git_source_path) { tmp_path + SecureRandom.hex(16) }
  let(:branch) { "the-branch" }
  let(:tag) { "the-tag" }
  let(:atag) { "the-atag" }

  before do
    git_source_path.mkpath
    Dir.chdir(git_source_path) do
      `git init`

      # master
      `touch butter.txt`
      `git add butter.txt`
      `git commit -m "Initial Commit"`

      # branch
      `git checkout -b #{branch} --quiet`
      `touch jam.txt`
      `git add jam.txt`
      `git commit -m "Branch Commit"`
      `git checkout master --quiet`

      # tag
      `git checkout -b deletable --quiet`
      `touch jelly.txt`
      `git add jelly.txt`
      `git commit -m "Tag Commit"`
      `git tag #{tag}`
      `git checkout master --quiet`
      `git branch -D deletable`

      # annotated tag
      `git checkout -b deletable --quiet`
      `touch jelly.txt`
      `git add jelly.txt`
      `git commit -m "Tag Commit"`
      `git tag -am "Annotated Tag Commit" #{atag}`
      `git checkout master --quiet`
      `git branch -D deletable`
    end
  end

  context "the original" do
    subject { described_class.new(env, git_source_path) }

    it "should recognize it" do
      subject.should be_git
    end

    it "should not list any remotes for it" do
      subject.remote_names.should be_empty
    end

    it "should not list any remote branches for it" do
      subject.remote_branch_names.should be_empty
    end
  end

  context "a clone" do
    let(:git_clone_path) { tmp_path + SecureRandom.hex(16) }
    subject { described_class.clone!(env, git_clone_path, git_source_path) }

    let(:master_sha) { subject.hash_from("origin", "master") }
    let(:branch_sha) { subject.hash_from("origin", branch) }
    let(:tag_sha) { subject.hash_from("origin", tag) }
    let(:atag_sha) { subject.hash_from("origin", atag) }

    it "should recognize it" do
      subject.should be_git
    end

    it "should have a single remote for it" do
      subject.should have(1).remote_names
    end

    it "should have a remote with the expected name" do
      subject.remote_names.first.should == "origin"
    end

    it "should have the remote branch" do
      subject.remote_branch_names["origin"].should include branch
    end

    it "should be checked out on the master" do
      subject.should be_checked_out(master_sha)
    end

    context "checking out the branch" do
      before do
        subject.checkout! branch
      end

      it "should be checked out on the branch" do
        subject.should be_checked_out(branch_sha)
      end

      it "should not be checked out on the master" do
        subject.should_not be_checked_out(master_sha)
      end
    end

    context "checking out the tag" do
      before do
        subject.checkout! tag
      end

      it "should be checked out on the tag" do
        subject.should be_checked_out(tag_sha)
      end

      it "should not be checked out on the master" do
        subject.should_not be_checked_out(master_sha)
      end
    end

    context "checking out the annotated tag" do
      before do
        subject.checkout! atag
      end

      it "should be checked out on the annotated tag" do
        subject.should be_checked_out(atag_sha)
      end

      it "should not be checked out on the master" do
        subject.should_not be_checked_out(master_sha)
      end
    end
  end

end

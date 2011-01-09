require 'spec_helper'

describe ProfileJob do

  before(:all) { Factory(:profile_job) }

  it { should have_db_column(:done_at).of_type(:datetime) }
  it { should belong_to :user }

  it { should validate_presence_of :user_id }

  before(:each) do
    LastFm::User.stub(:get_top_artists).and_return([])

    @done_job = Factory(:profile_job, :done_at => 2.minutes.ago)
    @todo_job = Factory(:profile_job)
  end

  describe "#unprocessed" do

    it "returns jobs with nil done_at timestamp" do
      unprocessed = ProfileJob.unprocessed
      unprocessed.should include(@todo_job)
      unprocessed.should_not include(@done_job)
    end
  end

  describe "#processed" do

    it "returns jobs with a valid done_at timestamp" do
      processed = ProfileJob.processed
      processed.should include(@done_job)
      processed.should_not include(@todo_job)
    end
  end

  describe "#done?" do

    it "returns true if done_at timestamp is present" do
      @done_job.done?.should be_true
    end

    it "returns false if done_at timestamp is blank" do
      @todo_job.done?.should_not be_true
    end
  end

  describe "#process" do

    before(:each) do
      LastFm::User.stub(:get_top_artists).and_return([])
    end

    it "calls User#build_profile" do
      @todo_job.user.should_receive(:build_profile)
      @todo_job.process
    end

    it "sets the done_at timestamp" do
      @todo_job.process
      @todo_job.done_at.should >= 1.second.ago
    end
  end

  describe ".process_all" do

    it "processes the unprocessed" do
      ProfileJob.process_all
      ProfileJob.unprocessed.count.should == 0
    end
  end
end

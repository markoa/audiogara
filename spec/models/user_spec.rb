require 'spec_helper'

describe User do

  it { should have_db_column(:lastfm_username).of_type(:string) }
  
  it { should have_many :interests }

  it { should validate_presence_of(:lastfm_username) }

  describe "#create_top_interests" do

    before(:each) do
      @user = Factory(:user)
    end

    context "when there is a known artist" do

      before do
        @artist = Factory(:artist, :name => "MGMT")
      end

      it "creates a new Interest for the corresponding Artist with score 1" do
        expect {
          @user.create_top_interests(["MGMT"])
        }.to change(Interest, :count).by(1)

        @user.reload
        @user.interests.should have(1).item

        interest = @user.interests.first
        interest.artist_name.should == "MGMT"
        interest.artist.should == @artist
        interest.score.should == 1
      end
    end

    context "when there is an unknown artist" do

      before do
        @mgmt = Factory(:artist, :name => "MGMT")
      end

      it "creates an Interest with just artist_name" do
        lambda {
          @user.create_top_interests(["MGMT", "Best Coast"])
        }.should_not change(Artist, :count)

        @user.reload
        @user.interests.should have(2).items

        @user.interests.where(:artist_name => "MGMT").first.artist.should == @mgmt
        @user.interests.where(:artist_name => "Best Coast").first.artist.should be_nil
      end
    end

    context "when it runs again for same input" do

      before do
        @interest = Factory(:interest, :user => @user, :artist_name => "MGMT")
      end

      it "does not make duplicates" do
        lambda {
          @user.create_top_interests(["MGMT"])
        }.should_not change(Interest, :count)
      end
    end
  end
end

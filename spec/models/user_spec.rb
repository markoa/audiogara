require 'spec_helper'

describe User do

  it { should have_db_column(:lastfm_username).of_type(:string) }
  
  it { should have_many :interests }

  it { should validate_presence_of(:lastfm_username) }

  describe "#create_interests" do

    before(:each) do
      @user = Factory(:user)
    end

    context "when working with artist names from listening history" do

      context "when there is a known artist" do

        before do
          @artist = Factory(:artist, :name => "MGMT")
        end

        it "creates a new Interest for the corresponding Artist with score 1" do
          expect {
            @user.create_interests(["MGMT"])
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
            @user.create_interests(["MGMT", "Best Coast"])
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
            @user.create_interests(["MGMT"])
          }.should_not change(Interest, :count)
        end
      end
    end

    context "when working with similar artist data" do

      before(:each) do
        @similar_artists_data = 
          [
            { :score => 1, :mbid => "af37c51c-0790-4a29-b995-456f98a6b8c9", :name => "Vampire Weekend" },
            { :score => 0.654495, :mbid => "63011a8d-0117-4f7e-9991-1ef1f337ff70", :name => "Klaxons" },
            { :score => 0.586866, :mbid => "f181961b-20f7-459e-89de-920ef03c7ed0", :name => "The Strokes" }
          ]
      end

      context "when they're all unknown" do

        it "creates new Interests with corresponding artist_names and scores" do

          lambda {
            @user.create_interests(@similar_artists_data)
          }.should_not change(Artist, :count)

          @user.reload
          @user.interests.should have(3).items

          interest_in_vw = @user.interests.where(:artist_name => "Vampire Weekend").first
          interest_in_vw.score.should == 1
          interest_in_vw.artist.should be_nil

          interest_in_klaxons = @user.interests.find_by_artist_name("Klaxons")
          interest_in_klaxons.score.should == 0.654495
          interest_in_klaxons.artist.should be_nil

          interest_in_strokes = @user.interests.find_by_artist_name("The Strokes")
          interest_in_strokes.score.should == 0.586866
          interest_in_strokes.artist.should be_nil
        end
      end

      context "when there is a known Artist" do
        
        before do
          @klaxons = Factory(:artist, :name => "Klaxons")
        end

        it "creates an Interest connected to that Artist" do
          @user.create_interests(@similar_artists_data)

          @user.reload
          @user.interests.should have(3).items

          interest_in_klaxons = @user.interests.where(:artist_name => "Klaxons").first
          interest_in_klaxons.artist.should == @klaxons
          interest_in_klaxons.score.should == 0.654495
        end
      end
    end
  end
end

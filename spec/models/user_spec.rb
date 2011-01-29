require 'spec_helper'

describe User do

  before(:all) { Factory(:user) }

  it { should have_db_column(:lastfm_username).of_type(:string) }
  it { should have_db_column(:lastfm_id).of_type(:integer) }
  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:realname).of_type(:string) }
  it { should have_db_column(:url).of_type(:string) }
  it { should have_db_column(:image_small).of_type(:string) }
  it { should have_db_column(:image_medium).of_type(:string) }
  it { should have_db_column(:image_large).of_type(:string) }
  it { should have_db_column(:image_extralarge).of_type(:string) }
  it { should have_db_column(:country).of_type(:string) }
  it { should have_db_column(:age).of_type(:integer) }
  it { should have_db_column(:gender).of_type(:string) }
  it { should have_db_column(:playcount).of_type(:integer) }
  it { should have_db_column(:registered).of_type(:date) }
  
  it { should have_one :profile_job }
  it { should have_many :interests }
  it { should have_many :ignored_artists }

  it { should validate_presence_of(:lastfm_username) }
  it { should validate_presence_of(:lastfm_id) }
  it { should validate_uniqueness_of(:lastfm_username) }

  describe "#create_interests" do

    before(:each) do
      @user = Factory(:user)
    end

    context "working with artist names from listening history" do

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

    context "working with raw similar artist data" do

      before(:each) do
        @similar_artists_data = 
          [
            { :score => 1, :mbid => "af37c51c-0790-4a29-b995-456f98a6b8c9", :name => "Vampire Weekend" },
            { :score => 0.654495, :mbid => "63011a8d-0117-4f7e-9991-1ef1f337ff70", :name => "Klaxons" },
            { :score => 0.586866, :mbid => "f181961b-20f7-459e-89de-920ef03c7ed0", :name => "The Strokes" },
            { :score => 0.0735582, :mbid => "cc197bad-dc9c-440d-a5b5-d52ba2e14234", :name => "Coldplay" }
          ]
      end

      context "when they're all unknown" do

        it "includes artists with similarity 0.43 or higher" do
          lambda {
            @user.create_interests(@similar_artists_data)
          }.should_not change(Artist, :count)

          @user.reload
          @user.interests.should have(3).items
          @user.interests.find_by_artist_name("Coldplay").should be_nil
        end

        it "creates new Interests with corresponding artist_names and scores" do

          lambda {
            @user.create_interests(@similar_artists_data)
          }.should_not change(Artist, :count)

          @user.reload
          @user.interests.should have(3).items

          interest_in_vw = @user.interests.find_by_artist_name("Vampire Weekend")
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

          interest_in_klaxons = @user.interests.find_by_artist_name("Klaxons")
          interest_in_klaxons.artist.should == @klaxons
          interest_in_klaxons.score.should == 0.654495
        end
      end
    end

    context "working with SimilarArtists of a known parent Artist" do

      before(:each) do
        @mgmt = Factory(:artist)
      end

      context "when SimilarArtist is a known Artist" do

        before(:each) do
          @vw = Factory(:artist, :name => "Vampire Weekend")

          @similar = Factory(:similar_artist,
                             :name => "Vampire Weekend",
                             :score => 1,
                             :parent_artist => @mgmt,
                             :artist => @vw)
        end

        it "creates an Interests connected to that Artist" do
          @user.create_interests([@similar])

          @user.reload
          @user.interests.should have(1).item

          interest_in_vw = @user.interests.find_by_artist_name("Vampire Weekend")
          interest_in_vw.artist.should == @vw
          interest_in_vw.score.should == 1
        end
      end

      context "when SimilarArtist is an unknown Artist" do

        before(:each) do
          @similar = Factory(:similar_artist,
                             :name => "Klaxons",
                             :score => 0.65,
                             :parent_artist => @mgmt)
        end

        it "creates an Interests with just artist_name" do
          @user.create_interests([@similar])

          @user.reload
          @user.interests.should have(1).item

          interest_in_klaxons = @user.interests.find_by_artist_name("Klaxons")
          interest_in_klaxons.artist.should be_nil
          interest_in_klaxons.score.should == 0.65
        end
      end
    end
  end

  describe "#interesting_torrents" do

    before(:each) do
      @user = Factory(:user)
      @mgmt = Factory(:artist, :name => "MGMT")
      @mgmt_torrent = Factory(:torrent, :artist => @mgmt)
      users_interest = Factory(:interest, :user => @user, :artist => @mgmt)

      @faithless = Factory(:artist, :name => "Faithless")
      @faithless_torrent = Factory(:torrent, :artist => @faithless)
      other_interest = Factory(:interest, :artist => @faithless)
    end

    it "returns torrents that match user's interests" do
      @user.interesting_torrents.should include(@mgmt_torrent)
      @user.interesting_torrents.should_not include(@faithless_torrent)
    end
  end

  describe "#rebuild_profile" do

    before(:each) do
      @top_artists = ["Johnny Cash", "Bob Dylan"]
      LastFm::User.stub(:get_top_artists).and_return(@top_artists)
      @user = Factory(:user)
    end

    it "calls create_interests for top artists from listening history" do
      @user.should_receive(:create_interests).once.with(@top_artists)
      @user.rebuild_profile
    end
  end

  describe "#profile_pending?" do

    before(:each) do
      @pending_user = Factory(:user)
      Factory(:profile_job, :user => @pending_user)

      @known_user = Factory(:user)
      Factory(:profile_job, :user => @known_user, :done_at => 2.days.ago)

      @beta_user_without_job = Factory(:user)
    end

    it "returns true if user has an unprocessed ProfileJob" do
      @pending_user.profile_pending?.should be_true
    end

    it "return false if user has a processed ProfileJob" do
      @known_user.profile_pending?.should be_false
    end

    it "returns false if user does not have a ProfileJob at all" do
      @beta_user_without_job.profile_pending?.should be_false
    end
  end

  describe "#update_profile_from_hash" do

    before(:each) do
      @hash = {
        :id => "1000002",
        :name => "RJ",
        :realname => "Richard Jones",
        :url => "http://www.last.fm/user/RJ",
        :image_small => "http://userserve-ak.last.fm/serve/34/8270359.jpg",
        :image_medium => "http://userserve-ak.last.fm/serve/64/8270359.jpg",
        :image_large => "http://userserve-ak.last.fm/serve/126/8270359.jpg",
        :image_extralarge => "http://userserve-ak.last.fm/serve/252/8270359.jpg",
        :country => "UK",
        :age => "28",
        :gender => "m",
        :playcount => "57119",
        :registered => "2002-11-20"
      }
      @user = Factory(:user)
    end

    it "updates attributes from Last.fm's get_info" do
      @user.update_profile_from_hash(@hash)

      @user.lastfm_id.should == 1000002
      @user.name.should == "RJ"
      @user.realname.should == "Richard Jones"
      @user.url.should == "http://www.last.fm/user/RJ"
      @user.image_small.should == "http://userserve-ak.last.fm/serve/34/8270359.jpg"
      @user.image_medium.should == "http://userserve-ak.last.fm/serve/64/8270359.jpg"
      @user.image_large.should == "http://userserve-ak.last.fm/serve/126/8270359.jpg"
      @user.image_extralarge.should == "http://userserve-ak.last.fm/serve/252/8270359.jpg"
      @user.country.should == "UK"
      @user.age.should == 28
      @user.gender.should == "m"
      @user.playcount.should == 57119
      @user.registered.to_s.should == "2002-11-20"
    end
  end
end

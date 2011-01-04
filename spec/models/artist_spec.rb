require 'spec_helper'

describe Artist do

  before(:all) { Factory(:torrent) }

  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:code).of_type(:string) }
  it { should have_db_column(:mbid).of_type(:string) }
  it { should have_db_column(:lastfm_url).of_type(:string) }
  it { should have_db_column(:image_small_url).of_type(:string) }
  it { should have_db_column(:image_medium_url).of_type(:string) }
  it { should have_db_column(:image_large_url).of_type(:string) }
  it { should have_db_column(:image_extralarge_url).of_type(:string) }
  it { should have_db_column(:image_mega_url).of_type(:string) }
  it { should have_db_column(:similars_processed_at).of_type(:datetime) }

  it { should have_many(:torrents) }
  it { should have_many(:similar_artists) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:lastfm_url) }

  it { should validate_uniqueness_of(:name) }

  describe ".codify" do
    it "creates a unique lowercase string of a name" do
      Artist.codify("AC/DC").should == "ac/dc"
    end
  end

  describe "#codename" do
    it "finds artist with given code" do
      acdc = Factory(:artist, :name => "AC/DC")
      Artist.codename("ac/dc").should == acdc
    end
  end

  describe ".before_create" do

    before(:each) do
      @best_coast = Factory(:artist, :name => "Best Coast")
      @mgmt = Factory(:artist, :name => "MGMT")
    end

    it "generates the code from the name" do
      @mgmt.code.should == "mgmt"
      @best_coast.code.should == "bestcoast"
    end
  end

  describe ".after_create" do

    before(:each) do
      @best_coast_interest = Factory(:interest, :artist_name => "Best Coast")

      @mgmt = Factory(:artist, :name => "MGMT")
      @mgmt_interest = Factory(:interest, :artist_name => "MGMT", :artist => @mgmt)

      @other_interest = Factory(:interest)
    end

    it "updates all Interests that were waiting for it to appear in the database" do
      best_coast = Factory(:artist, :name => "Best Coast")

      @best_coast_interest.reload
      @best_coast_interest.artist.should == best_coast
    end

    it "does not touch unrelated Interests" do
      @mgmt_interest.reload
      @other_interest.reload

      @mgmt_interest.artist.should == @mgmt
      @other_interest.artist.should be_nil
    end
  end

  describe ".named" do

    before do
      @mgmt = Factory(:artist, :name => "MGMT")
      @best_coast = Factory(:artist, :name => "Best Coast")
    end

    it "does a case-insensitive find by name" do
      Artist.named("best coast").should == [@best_coast]
    end
  end

  describe ".create_from_hash" do

    before do
      @hash = {
        :mbid=>"39ab1aed-75e0-4140-bd47-540276886b60",
        :image_small=>"http://userserve-ak.last.fm/serve/34/44937531.jpg",
        :image_medium=>"http://userserve-ak.last.fm/serve/64/44937531.jpg",
        :url=>"http://www.last.fm/music/Oasis",
        :image_large=>"http://userserve-ak.last.fm/serve/126/44937531.jpg",
        :image_extralarge=>"http://userserve-ak.last.fm/serve/252/44937531.jpg",
        :name=>"Oasis",
        :image_mega=>"http://userserve-ak.last.fm/serve/_/44937531/Oasis+Maine+Road.jpg"
      }
    end

    it "creates a new record from a hash from Last.fm" do
      expect { Artist.create_from_hash(@hash) }.to change(Artist, :count).by(1)

      artist = Artist.last
      artist.name.should == "Oasis"
      artist.mbid.should == @hash[:mbid]
      artist.lastfm_url.should == @hash[:url]
      artist.image_small_url.should == @hash[:image_small]
      artist.image_medium_url.should == @hash[:image_medium]
      artist.image_large_url.should == @hash[:image_large]
      artist.image_extralarge_url.should == @hash[:image_extralarge]
      artist.image_mega_url.should == @hash[:image_mega]
    end

    it "doesn't create a new record from an empty hash" do
      expect { Artist.create_from_hash({}) }.to change(Artist, :count).by(0)
    end
  end

  describe "#need_update_of_similar_artists" do

    before(:all) do
      @artist_with_similars = Factory(:artist, :similars_processed_at => 2.days.ago)
      @artist_with_similars_from_long_ago = Factory(:artist, :similars_processed_at => 1.month.ago)
      @artist_without_similars = Factory(:artist, :similars_processed_at => nil)
    end

    it "returns artists with nil processing timestamp" do
      results = Artist.need_update_of_similar_artists
      results.should include @artist_without_similars
      results.should_not include @artist_with_similars
    end

    it "returns artists with similar artist info fetched more than a month ago" do
      Artist.need_update_of_similar_artists.should include @artist_with_similars_from_long_ago
    end
  end

  describe "#update_similar_artists" do

    before do
      @mgmt = Factory(:artist, :similars_processed_at => 40.days.ago)
      @mgmt.similar_artists.create(:score => 1, :name => "Vampire Weekend")

      @sims = [
        { :name => "Vampire Weekend", :score => 0.9, :mbid => "433" },
        { :name => "Coldplay", :score => 0.1, :mbid => "123" }
      ]
    end

    it "refreshes and creates new similar artists using the results from Last.fm" do
      expect {
        @mgmt.update_similar_artists(@sims)
      }.to change(@mgmt.similar_artists, :count).by(1)

      @mgmt.similar_artists.find_by_name("Vampire Weekend").score.should == 0.9
      @mgmt.similar_artists.find_by_name("Coldplay").score.should == 0.1

      @mgmt.similars_processed_at.should >= 2.seconds.ago
    end
  end

end

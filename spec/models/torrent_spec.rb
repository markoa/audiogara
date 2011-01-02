require 'spec_helper'
require 'last_fm'

describe Torrent do

  before(:all) { Factory(:torrent) }

  it { should belong_to(:artist) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:link) }
  it { should validate_presence_of(:published_at) }

  it { should validate_uniqueness_of(:guid) }

  describe ".create_from_hash" do

    it "creates a new record from a parsed feed item" do
      hash = {
        :title => "Dr Dre - Krush",
        :guid => "http://thepiratebay.org/torrent/5961947/",
        :link => "http://thepiratebay.org/torrent/5961947/Dr_Dre_-_Krush.torrent",
        :published_at => "Wed, 17 Nov 2010 08:11:31 +0100"
      }

      expect { Torrent.create_from_hash(hash) }.to change(Torrent, :count).by(1)

      torrent = Torrent.last
      torrent.title.should == "Dr Dre - Krush"
      torrent.guid.should == "http://thepiratebay.org/torrent/5961947/"
      torrent.link.should == "http://thepiratebay.org/torrent/5961947/Dr_Dre_-_Krush.torrent"
      torrent.published_at.should == Time.parse("Wed, 17 Nov 2010 08:11:31 +0100")
      torrent.artist_name.should == "Dr Dre"
      torrent.album_name.should == "Krush"
    end

    it "doesn't create a new record if hash is missing valid artist or album info" do
      hash = {
        :title => "Dr Dre Discography",
        :guid => "http://thepiratebay.org/torrent/5961945/",
        :link => "http://thepiratebay.org/torrent/5961945/Dr_Dre_Discography.torrent",
        :published_at => "Wed, 17 Nov 2010 10:11:31 +0100"
      }

      proc { Torrent.create_from_hash(hash) }.should_not change(Torrent, :count)
    end

  end

  describe "#with_known_artist" do

    before do
      @torrent = Factory(:torrent, :artist => Factory(:artist))
      @torrent_with_unknown_artist = Factory(:torrent, :artist_id => nil)
    end

    it "returns torrents which reference an Artist" do
      Torrent.with_known_artist.should include @torrent
      Torrent.with_known_artist.should_not include @torrent_with_unknown_artist
    end
  end

  describe "#with_unprocessed_artist" do

    before do
      @torrent_with_unprocessed_artist =
        Factory(:torrent, :artist_id => nil, :artist_processed_at => nil)

      @torrent_with_processed_artist =
        Factory(:torrent, :artist_processed_at => 5.minutes.ago)
    end

    it "returns torrents with nil artist_processed_at timestamp" do
      Torrent.with_unprocessed_artist.should include @torrent_with_unprocessed_artist
      Torrent.with_unprocessed_artist.should_not include @torrent_with_processed_artist
    end
  end

  describe ".process_artists" do

    before(:each) do

      @last_fm_artist_fetcher = double("LastFm::Artist")
      @last_fm_artist_fetcher.stub(:get_info).and_return(
        {
          :mbid=>"",
          :image_small=>"http://userserve-ak.last.fm/serve/34/47091815.jpg",
          :image_medium=>"http://userserve-ak.last.fm/serve/64/47091815.jpg",
          :url=>"http://www.last.fm/music/CEO",
          :image_large=>"http://userserve-ak.last.fm/serve/126/47091815.jpg",
          :image_extralarge=>"http://userserve-ak.last.fm/serve/252/47091815.jpg",
          :name=>"CEO",
          :image_mega=>"http://userserve-ak.last.fm/serve/500/47091815/CEO+video2.jpg"
        }
      )

      @torrent_with_unprocessed_artist =
        Factory(:torrent,
                :title => "CEO - White Magic",
                :artist_name => "CEO",
                :album_name => "White Magic",
                :artist_id => nil,
                :artist_processed_at => nil)

      @torrent_with_same_artist_in_lowercase =
        Factory(:torrent,
                :title => "ceo - black magic",
                :artist_name => "Ceo",
                :album_name => "Black Magic",
                :artist_id => nil,
                :artist_processed_at => nil)

      @torrent_with_processed_artist =
        Factory(:torrent, :artist_processed_at => 5.minutes.ago)
    end

    it "gets artist info from Last.fm for all torrents that have not been processed yet" do
      expect { Torrent.process_artists(@last_fm_artist_fetcher) }.to change(Artist, :count).by(1)

      t = @torrent_with_unprocessed_artist.reload
      t.artist.should_not be_nil
      t.artist.name.should == "CEO"

      t.artist_processed_at.should_not be_nil
      t.artist_processed_at.should > 2.seconds.ago

      t2 = @torrent_with_same_artist_in_lowercase.reload
      t2.artist.should == t.artist

      @torrent_with_processed_artist.reload.artist_processed_at.should <= 5.minutes.ago
    end

  end

end

require 'spec_helper'

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

end

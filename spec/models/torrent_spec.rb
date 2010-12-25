require 'spec_helper'

describe Torrent do

  before(:all) { Factory(:torrent) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:link) }
  it { should validate_presence_of(:published_at) }

  it { should validate_uniqueness_of(:guid) }

  it "should create from hash made from a parsed feed item" do
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

  it "should not create from hash if it's missing valid artist or album info" do
    hash = {
      :title => "Dr Dre Discography",
      :guid => "http://thepiratebay.org/torrent/5961945/",
      :link => "http://thepiratebay.org/torrent/5961945/Dr_Dre_Discography.torrent",
      :published_at => "Wed, 17 Nov 2010 10:11:31 +0100"
    }

    proc { Torrent.create_from_hash(hash) }.should_not change(Torrent, :count)
  end

end

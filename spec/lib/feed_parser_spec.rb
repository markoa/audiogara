require 'spec_helper'
require 'feed_parser'

describe FeedParser do

  before(:all) do
    @tpb_feed = File.open("#{Rails.root}/spec/xml/tpb_feed.xml")
    @item = Nokogiri::XML <<-EOS
      <item>
        <title>Death In June - Peaceful Snow (2010)</title>
        <link>http://torrents.thepiratebay.org/5955234/Death_In_June_-_Peaceful_Snow_(2010).5955234.TPB.torrent</link>
        <comments>http://thepiratebay.org/torrent/5955234</comments>
        <pubDate>Sat, 13 Nov 2010 20:12:26 +0100</pubDate>
        <category domain="http://thepiratebay.org/browse/101">Audio / Music</category>
        <dc:creator>homer2008</dc:creator>
        <guid>http://thepiratebay.org/torrent/5955234/</guid>
        <enclosure url="http://torrents.thepiratebay.org/5955234/Death_In_June_-_Peaceful_Snow_(2010).5955234.TPB.torrent" length="12095" type="application/x-bittorrent" />
      </item>
    EOS
  end

  it "parses title, pubDate, guid, link from an item in TPB feed" do
    item = FeedParser.parse_tpb_item(@item)

    item[:title].should == "Death In June - Peaceful Snow (2010)"

    item[:published_at].should == "Sat, 13 Nov 2010 20:12:26 +0100"

    item[:guid].should == "http://thepiratebay.org/torrent/5955234/"

    item[:link].should == "http://torrents.thepiratebay.org/5955234/Death_In_June_-_Peaceful_Snow_(2010).5955234.TPB.torrent"
  end

  it "parses the TPB music feed" do
    items = FeedParser.parse_tpb_feed(@tpb_feed)
    items.size.should be 20
    items.first[:title].should == "VA - Top Of The Pops 1972 with covers"
    items[19][:guid].should == "http://thepiratebay.org/torrent/5961885/"
  end

end

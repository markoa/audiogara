require 'spec_helper'
require 'feed_parser'

describe FeedParser do

  describe ".parse_tpb_item" do

    before(:all) do
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
  end

  describe ".parse_tpb_feed" do

    before(:all) do
      @tpb_feed = File.open("#{Rails.root}/spec/xml/tpb_feed.xml")
    end

    it "parses the TPB music feed" do
      items = FeedParser.parse_tpb_feed(@tpb_feed)
      items.size.should be 20
      items.first[:title].should == "VA - Top Of The Pops 1972 with covers"
      items[19][:guid].should == "http://thepiratebay.org/torrent/5961885/"
    end
  end

  describe ".parse_demonoid_rows" do

    before(:all) do
      @title_row = Nokogiri::XML <<-EOS
        <td class="tone_1_pad" colspan="9">
          <a href="/files/details/2526173/002507363184/">Oasis - Rarer than Rare</a>
        </td>
      EOS

      @meta_row = Nokogiri::XML <<-EOS
      <tr>
        <td align="left" width="100%" class="tone_1_bl">
          <a class="subcategory" href="/files/?uid=0&amp;category=2&amp;subcategory=32&amp;language=0&amp;seeded=0&amp;quality=0&amp;query=&amp;sort=">Rock</a> :
          <a class="subcategory" href="/files/?uid=0&amp;category=2&amp;subcategory=0&amp;language=0&amp;seeded=0&amp;quality=16&amp;query=&amp;sort=">MP3/256Kbps</a>
          &nbsp;
        </td>
        <td align="left" nowrap="" class="tone_2_bl">
          <a class="user" href="/users/Robinldecker">
            <img width="8" height="8" border="0" title="Ratio: 0.34" alt="Ratio: 0.34" src="/images/ratio/n07.gif">
            <img width="2" height="1" border="0" alt="" src="/images/p.gif">
            Robinldecker
          </a>
        </td>
        <td align="center" nowrap="" class="tone_1_bl">
          <a href="/files/download/2526173/002507363184/">
            <img width="31" hspace="3" height="16" border="0" title="Download torrent" alt="Download torrent" src="/images/dmi.gif">
          </a>
          <a href="/files/downloadmagnet/2526173/002507363184/">
            <img width="35" hspace="3" height="16" border="0" title="Get magnet link" alt="Get magnet link" src="/images/mmi.gif">
          </a>
        </td>
        <td align="right" nowrap="" class="tone_2_bl">67.49 MB</td>
        <td align="center" nowrap="" class="tone_1_bl">0</td>
        <td align="center" nowrap="" class="tone_2_bl"><font class="blue">0</font></td>
        <td align="center" nowrap="" class="tone_1_bl"><font class="green">1</font></td>
        <td align="center" nowrap="" class="tone_2_bl"><font class="red">0</font></td>
        <td align="center" nowrap="" class="tone_1_bl">
          <img width="44" hspace="3" height="12" border="0" alt="" src="/images/hbars/14.jpg">
        </td>
      </tr>
      EOS
    end

    it "parses two rows that represent one torrent" do
      hash = FeedParser.parse_demonoid_rows(@title_row, @meta_row)
      hash[:title].should == "Oasis - Rarer than Rare"
      hash[:guid].should == "http://www.demonoid.me/files/details/2526173/002507363184/"
      hash[:link].should == "http://www.demonoid.me/files/download/2526173/002507363184/"
    end
  end

  describe ".parse_demonoid_page" do

    before(:all) do
      @page = File.open("#{Rails.root}/spec/xml/demonoid-music.html")
    end

    it "parses all torrents from the table" do
      items = FeedParser.parse_demonoid_page(@page)
      items.size.should be 50

      items.first[:title].should == "Kenny G-Songbird-The Best Of-[TFM]-2011"
      items.first[:guid].should == "http://www.demonoid.me/files/details/2526267/005850514096/"
      items.first[:link].should == "http://www.demonoid.me/files/download/2526267/005850514096/"
      Date.parse(items.first[:published_at]).should == Date.today

      items.last[:title].should == "Ervin Nyíregyházi Plays Grieg, Tchaikovsky, Blanchet, & Bortkiewicz (Vinyl rip)"
      items.last[:guid].should == "http://www.demonoid.me/files/details/2526052/001671575456/"
      items.last[:link].should == "http://www.demonoid.me/files/download/2526052/001671575456/"
    end

    context "maintainance or unavailability" do

      before(:all) do
        @page = "<html>Maintainance</html>"
      end

      it "doesn't break" do
        items = FeedParser.parse_demonoid_page(@page)
        items.should be_empty
      end
    end
  end

end

require 'spec_helper'
require 'title_parser'

describe TitleParser, "#parse" do

  it "unescapes HTML" do
    title = TitleParser.parse("Mamas &amp; Papas - Hip &amp; hop")
    title[:artist].should == "Mamas & Papas"
    title[:album].should == "Hip & Hop"
  end

  it "knows 'The Beatles - Revolver'" do
    title = TitleParser.parse("The Beatles - Revolver")

    title[:artist].should == "The Beatles"
    title[:album].should == "Revolver"
  end

  it "knows 'Australian Crawl - The Boys Light Up (1980)'" do
    title = TitleParser.parse("Australian Crawl - The Boys Light Up (1980)")

    title[:artist].should == "Australian Crawl"
    title[:album].should == "The Boys Light Up"
  end
  
  it "knows 'The Sorrow - The Sorrow [2010]'" do
    title = TitleParser.parse("The Sorrow - The Sorrow [2010]")

    title[:artist].should == "The Sorrow"
    title[:album].should == "The Sorrow"
  end

  it "knows 'Lil.Wayne - Hour.Past.Paid-(Bootleg)-2010-[NoFS]'" do
    title = TitleParser.parse("Lil.Wayne - Hour.Past.Paid-(Bootleg)-2010-[NoFS]")

    title[:artist].should == "Lil Wayne"
    title[:album].should == "Hour Past Paid"
  end

  it "knows 'Gorillaz - The Fall - 2010 (320 kbps MP3)'" do
    title = TitleParser.parse("Gorillaz - The Fall - 2010 (320 kbps MP3)")

    title[:artist].should == "Gorillaz"
    title[:album].should == "The Fall"
  end

  it "knows 'Flo Rida - Come With Me (New RnB)~Struzzin~'" do
    title = TitleParser.parse("Flo Rida - Come With Me (New RnB)~Struzzin~")

    title[:artist].should == "Flo Rida"
    title[:album].should == "Come With Me"
  end

  it "knows 'Devlin - Bud, Sweat And Beers - 2010'" do
    title = TitleParser.parse("Devlin - Bud, Sweat And Beers - 2010")

    title[:artist].should == "Devlin"
    title[:album].should == "Bud, Sweat And Beers"
  end

  it "knows 'Machinae Supremacy -2010- A View From The End Of The World'" do
    title = TitleParser.parse("Machinae Supremacy -2010- A View From The End Of The World")

    title[:artist].should == "Machinae Supremacy"
    title[:album].should == "A View From The End Of The World"
  end

  it "knows 'Massakren (USA) - 2010 - Immersed In Chaos'" do
    title = TitleParser.parse("Massakren (USA) - 2010 - Immersed In Chaos")

    title[:artist].should == "Massakren"
    title[:album].should == "Immersed In Chaos"
  end

  it "knows 'Reidar Larsen - Mr Blues Is Coming Twn - The Very Best Of (2003)'" do
    title = TitleParser.parse("Reidar Larsen - Mr Blues Is Coming Twn - The Very Best Of (2003)")

    title[:artist].should == "Reidar Larsen"
    title[:album].should == "Mr Blues Is Coming Twn"
  end

  it "knows 'Dethklok - Season 3 Songs'" do
    title = TitleParser.parse("Dethklok - Season 3 Songs")

    title[:artist].should == "Dethklok"
    title[:album].should == "Season 3 Songs"
  end

  it "skips 'The best Of Pantera CD'" do
    title = TitleParser.parse("The best Of Pantera CD")
    title.should be_blank
  end

  it "skips Various Artists" do
    title = TitleParser.parse("VA - Now that's what I call music")
    title.should be_blank

    title = TitleParser.parse("Various Artists - Now that's what I call music")
    title.should be_blank

    title = TitleParser.parse("Va Absolute Soul 3cd 320kbit Mp3 - Oeric")
    title.should be_blank
  end

  it "skips collections" do
    title = TitleParser.parse("MC Stevie Hyper D MP3 Collection - Lounge MP3]")
    title.should be_blank
  end

  it "skips ultimate collections" do
    title = TitleParser.parse("Black N Blue - Ultimate Collection")
    title.should be_blank
  end

  it "skips definitive collections" do
    title = TitleParser.parse("Greatest Ever Number 1s - The Definitive Collection")
    title.should be_blank
  end

  it "skips soundtracks" do
    title = TitleParser.parse("Assassin's Creed: Brotherhood - Soundtrack")
    title.should be_blank
  end

  it "skips discographies" do
    title = TitleParser.parse("Jefferson Airplane - Discography")
    title.should be_blank

    title = TitleParser.parse("Jefferson Airplane Discography - Something For All The Hippies")
    title.should be_blank
  end

  it "skips hits of decades" do
    title = TitleParser.parse("Eternal 70s Hits - Pure Gold")
    title.should be_blank
  end

  it "skips double cds" do
    title = TitleParser.parse("80's Wave - Entertainment Weekly Double Cd")
    title.should be_blank
  end

  it "skips cd sets" do
    title = TitleParser.parse("Elvis - 2cd Set")
    title.should be_blank
  end

  it "skips albums titled 'mp3'" do
    title = TitleParser.parse("Kis Hudh Tak - Mp3")
    title.should be_blank
  end

  it "skips best ofs" do
    title = TitleParser.parse("Best of Elvis - The Golden Ages")
    title.should be_blank
  end

  it "skips spam" do
    title = TitleParser.parse("Lil Wayne Im Not A Human Being M4a He - Aac Vbr Ipod Ipad Iphone")
    title.should be_blank
  end

  it "skips '001-Intro-Wabi~Sabi-Chancius-www.chancius.com.mp3'" do
    title = TitleParser.parse("001-Intro-Wabi~Sabi-Chancius-www.chancius.com.mp3")
    title.should be_blank
  end

  it "skips '101 70s Hits-5 CDs.2007'" do
    title = TitleParser.parse("101 70s Hits-5 CDs.2007")
    title.should be_blank
  end

  it "skips 'MP3-MAGIC-MARKA_Permanent-TheMixtape'" do
    title = TitleParser.parse("MP3-MAGIC-MARKA_Permanent-TheMixtape")
    title.should be_blank
  end

  it "skips 'O.S.T. - BioShock 2 - Songs From The Lighthouse (2010)'" do
    title = TitleParser.parse("O.S.T. - BioShock 2 - Songs From The Lighthouse (2010)")
    title.should be_blank
  end

  it "skips 'Pet Shop Boys Discography - 1986-2009, MP3@320kbps by NeroMo'" do
    title = TitleParser.parse("Pet Shop Boys Discography - 1986-2009, MP3@320kbps by NeroMo")
    title.should be_blank
  end

  it "skips 'Rocky IV Soundtrack - Hearts On Fire-Hyperdrive25.mp3'" do
    title = TitleParser.parse("Rocky IV Soundtrack - Hearts On Fire-Hyperdrive25.mp3")
    title.should be_blank
  end

  it "skips 'Techno-phobic - The rave theme.mp3'" do
    title = TitleParser.parse("Techno-phobic - The rave theme.mp3")
    title.should be_blank
  end

  it "skips 'DANCE - VA_-_Discoteka_2011_-_Dance_Club_Vol._31_(2011)'" do
    title = TitleParser.parse("DANCE - VA_-_Discoteka_2011_-_Dance_Club_Vol._31_(2011)")
    title.should be_blank
  end

  it "skips 'TEHNO - Alexandru_Popovici_-_January_2011_Chart_-_19.01.2011'" do
    title = TitleParser.parse("TEHNO - Alexandru_Popovici_-_January_2011_Chart_-_19.01.2011")
    title.should be_blank
  end

  it "skips 'TRANCE - A STATE OF SUNDAYS - 5 DJ\'S ON THE MIX'" do
    title = TitleParser.parse("TRANCE - A STATE OF SUNDAYS - 5 DJ\'S ON THE MIX")
    title.should be_blank
  end

  it "skips 'V.A. - Guitar Show '08 (2008) WMA320'" do
    title = TitleParser.parse("V.A. - Guitar Show '08 (2008) WMA320")
    title.should be_blank
  end

  it "skips 'Various - Discoparade estate 2000'" do
    title = TitleParser.parse("Various - Discoparade estate 2000")
    title.should be_blank
  end

  it "skips 'The Mix - Gone From Me'" do
    title = TitleParser.parse("The Mix - Gone From Me")
    title.should be_blank
  end

end

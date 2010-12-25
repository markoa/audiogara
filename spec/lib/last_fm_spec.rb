require 'spec_helper'
require 'last_fm'

describe LastFm do

  describe "Artist API" do

    before(:all) do
      File.open(File.join(Rails.root, "spec/xml", "artist-info.xml")) do |f|
        @the_xx = f.read
      end

      File.open(File.join(Rails.root, "spec/xml", "artist-info-error.xml")) do |f|
        @bad_artist = f.read
      end

      File.open(File.join(Rails.root, "spec/xml", "similar-artists.txt")) do |f|
        @similar_to_mgmt = f.read
      end
    end

    it "knows artist info" do
      artist = LastFm::Artist::get_info("The XX", @the_xx)
      artist[:name].should == "The xx"
      artist[:mbid].should == "123"
      artist[:url].should == "http://www.last.fm/music/The+xx"
      artist[:image_small].should == "http://userserve-ak.last.fm/serve/34/44887713.jpg"
      artist[:image_medium].should == "http://userserve-ak.last.fm/serve/64/44887713.jpg"
      artist[:image_large].should == "http://userserve-ak.last.fm/serve/126/44887713.jpg"
      artist[:image_extralarge].should == "http://userserve-ak.last.fm/serve/252/44887713.jpg"
      artist[:image_mega].should == "http://userserve-ak.last.fm/serve/_/44887713/The+xx+thexx.jpg"
    end

    it "recognizes error about unknown artist" do
      artist = LastFm::Artist.get_info("The XX", @bad_artist)
      artist.should == {}
    end

    it "knows similar artists" do
      sims = LastFm::Artist.get_similar("MGMT", @similar_to_mgmt)

      sims.first[:score].should == 1
      sims.first[:mbid].should == "af37c51c-0790-4a29-b995-456f98a6b8c9"
      sims.first[:name].should == "Vampire Weekend"

      sims.last[:score].should == 0.0735582
      sims.last[:mbid].should == "cc197bad-dc9c-440d-a5b5-d52ba2e14234"
      sims.last[:name].should == "Coldplay"
    end
  end
end

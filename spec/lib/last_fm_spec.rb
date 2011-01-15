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
      LastFm.stub(:fetch).and_return(@the_xx)
      artist = LastFm::Artist::get_info("The XX")
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
      LastFm.stub(:fetch).and_return(@bad_artist)
      artist = LastFm::Artist.get_info("The XX")
      artist.should == {}
    end

    it "knows similar artists" do
      LastFm.stub(:fetch).and_return(@similar_to_mgmt)
      sims = LastFm::Artist.get_similar("MGMT")

      sims.first[:score].should == 1
      sims.first[:mbid].should == "af37c51c-0790-4a29-b995-456f98a6b8c9"
      sims.first[:name].should == "Vampire Weekend"

      sims.last[:score].should == 0.0735582
      sims.last[:mbid].should == "cc197bad-dc9c-440d-a5b5-d52ba2e14234"
      sims.last[:name].should == "Coldplay"
    end
  end

  describe "User API" do

    describe ".get_top_artists" do

      before do
        File.open(File.join(Rails.root, "spec/xml", "top-artists.xml")) do |f|
          @top_artists = f.read
        end
      end

      it "knows user's top artists" do
        LastFm.stub(:fetch).and_return(@top_artists)
        artists = LastFm::User.get_top_artists("rj")
        artists.first.should == "Dream Theater"
        artists.last.should == "Jamiroquai"
        artists.count.should == 50
      end

    end

    describe ".get_info" do

      context "on success" do
      
        before(:each) do
          File.open(File.join(Rails.root, "spec/xml", "user-info.xml")) do |f|
            @rj_info = f.read
          end

          LastFm.stub(:fetch).and_return(@rj_info)
        end

        it "returns a hash with user info" do
          rj = LastFm::User.get_info("rj")

          rj.should_not have_key(:error)

          rj[:id].should == "1000002"
          rj[:name].should == "RJ"
          rj[:realname].should == "Richard Jones"
          rj[:url].should == "http://www.last.fm/user/RJ"
          rj[:image_small].should == "http://userserve-ak.last.fm/serve/34/8270359.jpg"
          rj[:image_medium].should == "http://userserve-ak.last.fm/serve/64/8270359.jpg"
          rj[:image_large].should == "http://userserve-ak.last.fm/serve/126/8270359.jpg"
          rj[:image_extralarge].should == "http://userserve-ak.last.fm/serve/252/8270359.jpg"
          rj[:country].should == "UK"
          rj[:age].should == "28"
          rj[:gender].should == "m"
          rj[:playcount].should == "57119"
          rj[:registered].should == "2002-11-20"
        end
      end

      context "on error" do

        before(:each) do
          File.open(File.join(Rails.root, "spec/xml", "user-info-error.xml")) do |f|
            @error_response = f.read
          end

          LastFm.stub(:fetch).and_return(@error_response)
        end

        it "returns a hash with error description" do
          rj = LastFm::User.get_info("rj")

          rj.should have(1).key
          rj[:error].should == "No user with that name was found"
        end
      end
    end
  end
end

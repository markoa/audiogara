require 'spec_helper'

describe Artist do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:lastfm_url) }

  it { should have_many(:torrents) }

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

end

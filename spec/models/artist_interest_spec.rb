require 'spec_helper'

describe ArtistInterest do

  describe ".initialize" do

    before(:each) do
      @ai = ArtistInterest.new(:name => "Smith Westerns", :score => 0.9)
    end

    it "initializes with name and score, infers code itself" do
      @ai.name.should == "Smith Westerns"
      @ai.score.should == 0.9
      @ai.code.should == "smithwesterns"
    end
  end

  describe ".factory" do

    context "given an array of strings (from user listening history)" do

      before(:each) do
        @artists = ["Smith Westerns", "Caesars"]
      end

      it "returns ArtistInterest objects with scores set to 1" do
        ais = ArtistInterest.factory(@artists)
        ais.size.should == 2

        sw = ais.first
        sw.name.should == "Smith Westerns"
        sw.score.should == 1

        c = ais.second
        c.name.should == "Caesars"
        c.score.should == 1
      end
    end

    context "given an array of hashes (from similar artists API)" do

      before(:each) do
        @artists =
          [
            { :score => 1, :mbid => "af37c51c-0790-4a29-b995-456f98a6b8c9", :name => "Vampire Weekend" },
            { :score => 0.654495, :mbid => "63011a8d-0117-4f7e-9991-1ef1f337ff70", :name => "Klaxons" },
            { :score => 0.586866, :mbid => "f181961b-20f7-459e-89de-920ef03c7ed0", :name => "The Strokes" },
            { :score => 0.0735582, :mbid => "cc197bad-dc9c-440d-a5b5-d52ba2e14234", :name => "Coldplay" }
          ]
      end

      it "returns ArtistInterest objects for similar artists with scores higher than #{Artist::MIN_SIMILARITY}" do
        ais = ArtistInterest.factory(@artists)
        ais.size.should == 3

        ais.first.name.should == "Vampire Weekend"
        ais.first.score.should == 1

        ais.third.name.should == "The Strokes"
        ais.third.score.should == 0.586866
      end
    end

    context "given an array of SimilarArtist objects" do

      before(:each) do
        @good_similar = Factory(:similar_artist,
                                :name => "Vampire Weekend",
                                :score => 0.7)

        @obscure_similar = Factory(:similar_artist,
                                   :name => "Takeshi Okinawa",
                                   :score => 0.4)
      end

      it "returns ArtistInterest objects for similar artists with scores higher than #{Artist::MIN_SIMILARITY}" do
        ais = ArtistInterest.factory([@good_similar, @obscure_similar])
        ais.size.should == 1

        ais.first.name.should == "Vampire Weekend"
        ais.first.score.should == 0.7
      end
    end
  end

end

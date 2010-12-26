require 'spec_helper'

describe SimilarArtist do

  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:mbid).of_type(:string) }
  it { should have_db_column(:score).of_type(:float) }

  it { should belong_to(:artist) }
  it { should belong_to(:parent_artist) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:score) }

  describe ".link_with_known_artists" do

    before do
      @mgmt = Factory(:artist, :name => "MGMT")
      @vampire_weekend = Factory(:artist, :name => "Vampire Weekend")

      @the_strokes_sa = Factory(:similar_artist,
                                :name => "The Strokes",
                                :parent_artist => @mgmt)

      @vampire_weekend_sa = Factory(:similar_artist,
                                    :name => "Vampire Weekend",
                                    :parent_artist => @mgmt)
    end

    it "links SimilarArtists with Artists of same name if they exist" do
      SimilarArtist.link_with_known_artists

      @the_strokes_sa.reload && @vampire_weekend_sa.reload
      @the_strokes_sa.artist.should be_nil
      @vampire_weekend_sa.artist.should == @vampire_weekend
    end
  end
end

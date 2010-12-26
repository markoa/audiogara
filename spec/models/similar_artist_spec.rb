require 'spec_helper'

describe SimilarArtist do

  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:mbid).of_type(:string) }
  it { should have_db_column(:score).of_type(:float) }

  it { should belong_to(:artist) }
  it { should belong_to(:parent_artist) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:score) }
end

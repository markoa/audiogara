require 'spec_helper'

describe SimilarArtist do

  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:mbid).of_type(:string) }

  it { should belong_to(:artist) }
  it { should belong_to(:parent_artist) }

  it { should validate_presence_of(:name) }
end

require 'spec_helper'

describe IgnoredArtist do

  before(:all) { Factory(:ignored_artist) }

  it { should have_db_column(:name).of_type(:string) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user_id) }

end

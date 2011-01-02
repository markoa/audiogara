require 'spec_helper'

describe User do

  it { should have_db_column(:lastfm_username).of_type(:string) }

  it { should validate_presence_of(:lastfm_username) }
end

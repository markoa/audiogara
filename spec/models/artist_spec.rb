require 'spec_helper'

describe Artist do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:lastfm_url) }

  it { should have_many(:torrents) }

end

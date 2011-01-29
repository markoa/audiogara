require 'spec_helper'

describe IgnoredArtist do

  it { should belong_to(:artist) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:artist_id) }
  it { should validate_presence_of(:user_id) }

end

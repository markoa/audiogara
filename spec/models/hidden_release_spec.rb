require 'spec_helper'

describe HiddenRelease do

  it { should have_db_column(:artist_name).of_type(:string) }
  it { should have_db_column(:album_name).of_type(:string) }
  it { should have_db_column(:reason).of_type(:integer) }

  it { should belong_to(:user) }

  it { should validate_presence_of(:artist_name) }
  it { should validate_presence_of(:album_name) }
  it { should validate_presence_of(:reason) }
  it { should validate_presence_of(:user_id) }

  it { should ensure_inclusion_of(:reason).in_range(1..2) }

end

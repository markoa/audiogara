require 'spec_helper'

describe Interest do

  it { should belong_to :user }
  it { should belong_to :artist }
  it { should have_db_column(:score).of_type(:float) }
  it { should have_db_column(:artist_name).of_type(:string) }
  it { should have_db_column(:artist_processed_at).of_type(:datetime) }
  
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :score }
  it { should validate_presence_of :artist_name }
end

require 'spec_helper'

describe Interest do

  before(:all) { Factory(:interest) }

  it { should belong_to :user }
  it { should belong_to :artist }
  it { should have_db_column(:score).of_type(:float) }
  it { should have_db_column(:artist_name).of_type(:string) }
  it { should have_db_column(:artist_processed_at).of_type(:datetime) }
  
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :score }
  it { should validate_presence_of :artist_name }

  it "should require case sensitive unique value for artist_name within the scope of a user" do
    user = Factory(:user)
    i = Factory(:interest, :user => user)

    expect {
      i2 = Factory(:interest, :user => user, :artist_name => i.artist_name)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

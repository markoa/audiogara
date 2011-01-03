require 'spec_helper'

describe Interest do

  before(:all) { Factory(:interest) }

  it { should belong_to :user }
  it { should belong_to :artist }
  it { should have_db_column(:score).of_type(:float) }
  it { should have_db_column(:artist_name).of_type(:string) }
  
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :score }
  it { should validate_presence_of :artist_name }

  it "should require case sensitive unique value for artist_name within the scope of a user" do
    user = Factory(:user)

    i = Factory.create(:interest, :user => user)
    i.should be_valid

    i2 = Factory.build(:interest, :user => user, :artist_name => i.artist_name)
    i2.should_not be_valid
    i2.should have(1).error_on(:artist_name)
  end

  describe "#waiting_for_artist" do

    before(:each) do
      @best_coast_interest_1 = Factory(:interest, :artist_name => "Best Coast")
      @best_coast_interest_2 = Factory(:interest, :artist_name => "Best Coast")
      @mgmt_interest = Factory(:interest, :artist_name => "MGMT")
    end

    it "returns Interests that have artist_name same as given input and with nil artist_id" do
      results = Interest.waiting_for_artist("Best Coast")
      results.should have(2).items
      results.should include(@best_coast_interest_1)
      results.should include(@best_coast_interest_2)
    end
  end

  describe "#known" do
    before(:each) do
      @best_coast_interest = Factory(:interest, :artist_name => "Best Coast")
      @mgmt_interest = Factory(:interest, :artist_name => "MGMT", :artist => Factory(:artist))
    end

    it "returns Interests with a non-nil artist_id" do
      results = Interest.known
      results.should_not include(@best_coast_interest)
      results.should include(@mgmt_interest)
    end
  end
end

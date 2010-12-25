require 'spec_helper'

describe Torrent do

  before(:all) { Factory(:torrent) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:link) }
  it { should validate_presence_of(:published_at) }

  it { should validate_uniqueness_of(:guid) }

end

require 'spec_helper'

describe "users/show.html.erb" do
  
  let(:user) { mock_model(User).as_null_object }

  let(:torrent) { mock_model(Torrent).as_null_object }

  before(:each) do
    torrent.stub(:artist_name).and_return("MGMT")
    torrent.stub(:album_name).and_return("Congratulations")
    torrent.stub(:published_at).and_return(Time.now)
    torrent.stub(:created_at).and_return(Time.now)

    assign("user", user)
    assign("interesting_torrents", [torrent])
  end
  
  it "renders a personalized greeting" do
    user.stub(:lastfm_username).and_return("rj")
    render
    rendered.should contain("Hi rj!")
  end

  it "lists torrents of artists that come from matching interests" do
    render
    rendered.should contain("Congratulations")
  end
end

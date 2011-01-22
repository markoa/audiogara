require 'spec_helper'

describe "users/show.html.erb" do
  
  let(:user) { mock_model(User).as_null_object }

  let(:torrent) { mock_model(Torrent).as_null_object }

  before(:each) do
    view.stub(:current_user).and_return(user)

    user.stub(:lastfm_username).and_return("rj")

    torrent.stub(:artist_name).and_return("MGMT")
    torrent.stub(:album_name).and_return("Congratulations")
    torrent.stub(:published_at).and_return(Time.now)
    torrent.stub(:created_at).and_return(Time.now)

    assign("user", user)
    assign("interesting_torrents", [torrent])
  end

  context "user is viewing own profile" do
  
    it "renders a personalized greeting and a link to sign out" do
      render
      rendered.should contain("Hi rj")
      rendered.should contain("Sign out")
    end

    it "lists torrents of artists that come from matching interests" do
      render
      rendered.should contain("Congratulations")
    end

    context "when there are no suggestions" do

      before(:each) do
        assign("interesting_torrents", [])
        assign("known_interests_count", 100)
      end

      it "says sorry" do
        render
        rendered.should have_selector("#sorryNoTorrents")
      end

      context "when there are very few known interests" do

        before(:each) do
          assign("known_interests_count", 51)
        end

        it "says we don't know much about you" do
          render
          rendered.should have_selector("#dontKnowMuch")
        end
      end
    end
  end

  context "user is viewing another profile" do

    before(:each) do
      another_user = mock_model(User).as_null_object
      view.stub(:current_user).and_return(another_user)
    end

    it "does not render a personalized greeting and a link to sign out" do
      render
      rendered.should_not contain("Hi")
      rendered.should_not contain("Sign out")
    end
  end
end

require 'spec_helper'
require 'last_fm'

describe UsersController do

  let(:user) { mock_model(User).as_null_object }

  describe "GET new" do

    context "when user is logged in" do

      it "redirects to the profile page" do
        @request.cookies[:lastfm_username] = "rj"
        get :new
        response.should redirect_to(:action => "show", :id => "rj")
      end
    end

    context "when user is not logged in" do

      it "shows the form" do
        get :new
        response.should render_template("users/new")
      end

      it "prepares a new user" do
        User.should_receive(:new).and_return(user)
        get :new
        assigns[:user].should == user
      end
    end
  end

  describe "POST create" do

    context "when username exists" do

      before(:each) do
        user.stub(:present?).and_return(true)
        user.stub(:lastfm_username).and_return("rj")
        user.stub(:to_param).and_return("rj")
        User.stub(:find_by_lastfm_username).and_return(user)
      end

      it "redirects to the user profile" do
        post :create
        response.should redirect_to(user)
      end

      it "sets the cookie to remember her and log her in" do
        post :create
        cookies["lastfm_username"].should == "rj"
      end
    end

    context "when username does not exist" do

      before(:each) do
        User.stub(:find_by_lastfm_username).and_return(nil)
        User.stub(:new).and_return(user)
      end

      context "when last.fm username is verified" do

        before(:each) do
          LastFm::User.should_receive(:get_info).and_return({ :lastfm_id => 1000 })
          user.stub(:lastfm_username).and_return("rj")
          user.stub(:to_param).and_return("rj")
        end
        
        it "saves the user with last.fm info" do
          user.should_receive(:update_profile_from_hash)
          post :create
        end

        it "creates a ProfileJob" do
          user.should_receive(:create_profile_job)
          post :create
        end

        it "sets a welcoming flash[:notice] message" do
          post :create
          flash[:notice].should == "Welcome aboard!"
        end

        it "redirects to the user profile" do
          post :create
          response.should redirect_to(user)
        end

        it "sets the cookie to remember her and log her in" do
          post :create
          cookies["lastfm_username"].should == "rj"
        end
      end

      context "when last.fm username is invalid" do

        before do
          LastFm::User.should_receive(:get_info).and_return({ :error => "Name not found" })
        end

        it "does not attempt to save" do
          post :create
          user.should_not_receive(:save)
        end

        it "renders the new template" do
          post :create
          response.should render_template("new")
        end

        it "sets an informing flash[:notice] message" do
          post :create
          flash[:notice].should == "Name not found"
        end
      end
    end
  end

  describe "GET show" do

    context "when user exists" do

      let(:torrent) { mock_model(Torrent).as_null_object }

      before do
        User.should_receive(:find_by_lastfm_username).and_return(user)
      end

      context "and has a pending profile" do

        before(:each) do
          user.should_receive(:profile_pending?).and_return(true)
        end

        it "renders the profile pending template" do
          get :show, :id => "rj"
          response.should render_template("profile_pending")
        end
      end

      context "and has a known profile" do

        before(:each) do
          user.should_receive(:profile_pending?).and_return(false)
        end

        it "finds her by lastfm_username" do
          get :show, :id => "rj"
          assigns[:user].should be user
        end

        it "loads interesting torrents" do
          torrents = [torrent]
          user.should_receive(:interesting_torrents).and_return(torrents)
          get :show, :id => "rj"
          assigns[:interesting_torrents].should == torrents
        end

        context "when there are no suggestions" do

          before(:each) do
            user.stub(:interesting_torrents).and_return([])
          end

          it "counts the number of known interests" do
            counter = double("interest")
            counter.should_receive(:count)
            user.stub_chain(:interests, :known).and_return(counter)
            get :show, :id => "rj"
          end
        end
      end
    end

    context "when user does not exist" do

      before do
        User.should_receive(:find_by_lastfm_username).and_return(nil)
      end

      it "shows the not found page" do
        expect {
          get :show, :id => "rj"
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST signout" do

    before(:each) do
      User.should_receive(:find_by_lastfm_username).and_return(user)
      user.stub(:lastfm_username).and_return("rj")
    end

    context "when user has a cookie" do

      before(:each) do
        @request.cookies[:lastfm_username] = "rj"
      end

      it "clears the user's cookie" do
        post :signout, :id => "rj"
        cookies["lastfm_username"].should be_nil
      end

      it "redirects to the home page" do
        post :signout, :id => "rj"
        response.should redirect_to(root_path)
      end
    end

    context "when user does not have a cookie" do

      before(:each) do
        @request.cookies[:lastfm_username] = nil
      end

      it "redirects to the home page" do
        post :signout, :id => "rj"
        response.should redirect_to(root_path)
      end
    end
  end

  describe "POST ignore_artist" do

    before(:each) do
      User.should_receive(:find_by_lastfm_username).and_return(user)
      Artist.should_receive(:find).and_return(mock_model(Artist))
    end

    it "ignores artist" do
      user.should_receive(:ignore_artist)
      post :ignore_artist, :id => 1, :artist_id => 10
    end

    it "returns only the status code of success" do
      user.stub(:ignore_artist)
      post :ignore_artist, :id => 1, :artist_id => 10
      response.should be_success
    end
    
  end

  describe "POST ignore_album" do
    
    before(:each) do
      User.should_receive(:find_by_lastfm_username).and_return(user)
      Torrent.should_receive(:find).and_return(mock_model(Torrent))
    end

    it "hides release as not interesting" do
      user.should_receive(:hide_release_as_not_interesting)
      post :ignore_album, :id => 1, :torrent_id => 20
    end

    it "returns only the status code of success" do
      user.stub(:hide_release_as_not_interesting)
      post :ignore_album, :id => 1, :torrent_id => 20
      response.should be_success
    end
  end

  describe "POST own_album" do
    
    before(:each) do
      User.should_receive(:find_by_lastfm_username).and_return(user)
      Torrent.should_receive(:find).and_return(mock_model(Torrent))
    end

    it "hides album as owned" do
      user.should_receive(:hide_release_as_owned)
      post :own_album, :id => 1, :torrent_id => 20
    end

    it "returns only the status code of success" do
      user.stub(:hide_release_as_owned)
      post :own_album, :id => 1, :torrent_id => 20
      response.should be_success
    end
  end

end

require 'spec_helper'

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
        user.stub(:rebuild_profile)
        User.stub(:find_by_lastfm_username).and_return(user)
      end

      it "rebuilds the user profile" do
        user.should_receive(:rebuild_profile)
        post :create, :user => {} # necessary because of the 'unless' in controller
      end

      it "redirects to the user profile" do
        post :create, :user => {}
        response.should redirect_to(user)
      end

      it "sets the cookie to remember her and log her in" do
        post :create, :user => {}
        cookies["lastfm_username"].should == "rj"
      end
    end

    context "when username does not exist" do

      before do
        User.stub(:find_by_lastfm_username).and_return(nil)
        User.stub(:new).and_return(user)
      end

      context "when the user saves successfully" do

        before do
          user.stub(:save).and_return(true)
          user.stub(:lastfm_username).and_return("rj")
          user.stub(:to_param).and_return("rj")
        end

        it "builds the user profile" do
          user.should_receive(:build_profile)
          post :create
        end

        it "sets a flash[:notice] message" do
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

      context "when the user fails to save" do

        before do
          user.stub(:save).and_return(false)
        end

        it "assigns @user" do
          post :create
          assigns[:user].should == user
        end

        it "renders the new template" do
          user.stub(:save).and_return(false)
          post :create
          response.should render_template("new")
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
end

require 'spec_helper'

describe UsersController do

  let(:user) { mock_model(User).as_null_object }

  describe "POST create" do

    before(:each) do
      User.stub(:new).and_return(user)
    end

    it "creates a new user" do
      User.should_receive(:new).
        with("lastfm_username" => "rj").
        and_return(user)
      post :create, :user => { :lastfm_username => "rj" }
    end

    context "when the user saves successfully" do

      before do
        user.stub(:save).and_return(true)
      end

      it "sets a flash[:notice] message" do
        post :create
        flash[:notice].should == "Welcome aboard!"
      end

      it "redirects to the user profile" do
        post :create
        response.should redirect_to(assigns[:user])
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

  describe "GET show" do

    context "when user exists" do

      before do
        User.should_receive(:find_by_lastfm_username).and_return(user)
      end

      it "finds her by lastfm_username" do
        get :show, :lastfm_username => "rj"
        assigns[:user].should be user
      end
    end

    context "when user does not exist" do

      before do
        User.should_receive(:find_by_lastfm_username).and_return(nil)
      end

      it "shows the not found page" do
        expect {
          get :show, :lastfm_username => "rj"
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

end

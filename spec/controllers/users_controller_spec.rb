require 'spec_helper'

describe UsersController do

  describe "POST create" do

    let(:user) { mock_model(User).as_null_object }
    
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

end

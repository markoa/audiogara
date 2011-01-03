require 'spec_helper'

describe "users/new.html.erb" do
  
  let(:user) do
    mock_model("User").as_new_record.as_null_object
  end

  before(:each) do
    assign("user", user)
  end
  
  it "renders a form to signup with a last.fm username" do
    render
    rendered.should have_selector("form", :method => "post", :action => users_path) do |form|
      form.should have_selector("input", :type => "submit")
      form.should have_selector("input", :id => "user_lastfm_username")
    end
  end
end

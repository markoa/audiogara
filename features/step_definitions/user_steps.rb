Given /^I am logged in as "([^"]*)"$/ do |username|
  @user = Factory(:user, :lastfm_username => username)
  steps %Q{
    Given I am on the home page
    And I fill in "user_lastfm_username" with "#{username}"
    And I press "Show me"
  }
end

Given /^I have a recommendation "([^"]*)" \- "([^"]*)"$/ do |artist_name, album_name|

  tmp = Artist.where(:name => artist_name).first
  if tmp.present?
    artist = tmp
  else
    artist = Factory(:artist, :name => artist_name)
  end

  interest = @user.interests.where(:artist_name => artist_name).first
  if interest.nil?
    @user.interests.create(:artist => artist,
                           :artist_name => artist_name,
                           :score => 0.7)
  end

  Factory(:torrent,
          :artist => artist,
          :artist_name => artist_name,
          :album_name => album_name,
          :title => "#{artist_name} - #{album_name}")
end

Given "I am in" do
  visit("/")
end

Given /^I wait for (\d+) seconds$/ do |sec|
  sleep(sec.to_i)
end

When /^I reload the page$/ do
  visit(current_path)
end

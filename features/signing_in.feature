Feature: Signing in and viewing recommendations

  Users open the home page, see a text field, enter their Last.fm username
  and click a button. After a while they see their profile page. Their
  username is stored in a cookie, and future access to root path redirects
  to their profile page.

  Scenario: Signing in
    Given Last.fm is fake
    When I go to the home page
    And I fill in "user_lastfm_username" with "rj"
    And I press "Show me"
    Then I should see "Hi rj!"

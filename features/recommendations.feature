Feature: managing interests

  On their profile page, users see a number of recommended releases.
  They can mark each as owned, hide a recommendation or choose to ignore
  all releases by a certain artist.

  @javascript
  Scenario: Ignoring an artist
    Given Last.fm is fake
    And I am logged in as "rj"
    And I have a recommendation "Tim Hecker" - "Adventures in ultraviolet"
    And I have a recommendation "Simple Minds" - "Once upon a time"
    And I have a recommendation "Simple Minds" - "Sparkle in the rain"
    And I am in
    When I follow "hide"
    And I follow "all by Simple Minds"
    Then I should not see "Simple Minds"
    When I reload the page
    Then I should see "Tim Hecker"
    And I should not see "Simple Minds"

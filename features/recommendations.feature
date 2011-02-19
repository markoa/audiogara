Feature: managing interests

  On their profile page, users see a number of recommended releases.
  They can mark each as owned, hide a recommendation or choose to ignore
  all releases by a certain artist.

  Background:
    Given Last.fm is fake
    And I am logged in as "rj"
    And I have a recommendation "Tim Hecker" - "Adventures in ultraviolet"
    And I have a recommendation "Simple Minds" - "Once upon a time"
    And I have a recommendation "Simple Minds" - "Sparkle in the rain"
    And I am in

  @javascript
  Scenario: Ignoring an artist
    When I follow "ignore"
    And I follow "all by Simple Minds"
    Then I should not see "Simple Minds"
    When I reload the page
    Then I should see "Tim Hecker"
    And I should not see "Simple Minds"

  @javascript
  Scenario: Hiding a release
    When I follow "ignore"
    And I follow "this album"
    Then I should not see "Simple Minds - Sparkle In The Rain"
    But I should see "Simple Minds - Once Upon A Time"
    And I should see "Tim Hecker - Adventures In Ultraviolet"
    When I reload the page
    Then I should not see "Simple Minds - Sparkle In The Rain"
    But I should see "Simple Minds - Once Upon A Time"
    And I should see "Tim Hecker - Adventures In Ultraviolet"

  @javascript
  Scenario: Marking a release as owned
    When I follow "I have this"
    Then I should not see "Simple Minds - Sparkle In The Rain"
    But I should see "Simple Minds - Once Upon A Time"
    And I should see "Tim Hecker - Adventures In Ultraviolet"
    When I reload the page
    Then I should not see "Simple Minds - Sparkle In The Rain"
    But I should see "Simple Minds - Once Upon A Time"
    And I should see "Tim Hecker - Adventures In Ultraviolet"

  @javascript @new
  Scenario: Viewing an artist
    When I follow "Tim Hecker"
    Then I should see "Adventures In Ultraviolet"
    And I should see "download"
    But I should not see "I have this"
    And I should not see "ignore"

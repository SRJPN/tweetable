@omniauth_test
Feature: Admin page

  Scenario: Search for the website
    Given I am on the Tweetable login homepage
    Then I should see "Tweetable"
    Then As an admin user I click on login with Facebook
    Then I should see "Opened" exercises
    Then I should see "Saved" exercises
#    Then I should see "Evaluated"
    Then I should see "New" exercises

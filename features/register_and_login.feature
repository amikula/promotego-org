Feature: Manage registers
  In order to use the site
  the user
  wants to register and login

  Scenario: See the register link
    Given I am on the homepage
    Then I should see "Register"

  Scenario: Click on the register link
    Given I am on the homepage
    When I follow "Register"
    Then I should be on the new account page

  Scenario: Register an account
    Given I am on the new account page
    When I fill in the following:
      | Login             | test              |
      | Email             | test@example.com  |
      | Password          | pass1234          |
      | Confirm Password  | pass1234          |
    And I press "Sign up"
    Then I should be on the validation message page

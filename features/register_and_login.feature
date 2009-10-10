Feature: Register users
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

  Scenario: Password doesn't match when registering
    Given I am on the new account page
    When I fill in the following:
        | Login             | test              |
        | Email             | test@example.com  |
        | Password          | pass1234          |
        | Confirm Password  | pass123           |
      And I press "Sign up"
    Then I should be on the account page
      And I should see "doesn't match"

  Scenario: Password is invalid when registering
    Given I am on the new account page
    When I fill in the following:
        | Login             | test              |
        | Email             | test@example.com  |
        | Password          | pass              |
        | Confirm Password  | pass              |
      And I press "Sign up"
    Then I should be on the account page
      And I should see "too short"

  Scenario: Account is not active before clicking on email validation link
    Given I am on the new account page
    When I fill in the following:
        | Login             | test              |
        | Email             | test@example.com  |
        | Password          | pass1234          |
        | Confirm Password  | pass1234          |
      And I press "Sign up"
    Then user "test" should not be active

  Scenario: Click on link in registration email
    Given I am on the new account page
    When I fill in the following:
        | Login             | test              |
        | Email             | test@example.com  |
        | Password          | pass1234          |
        | Confirm Password  | pass1234          |
      And I press "Sign up"
      And I receive an email to "test@example.com"
      And I click on the first link in the email
    Then I should be on the homepage
      And user "test" should be active

  Scenario: Log in with an activated account
    Given there is a User like the following:
        | Login                 | test             |
        | Password              | pass1234         |
        | Password Confirmation | pass1234         |
        | Email                 | test@example.com |
        | Active                | true             |
      And that User is active
      And I am on the homepage
    When I follow "Log in"
    Then I should be on the login page
    When I fill in the following:
        | Login    | test     |
        | Password | pass1234 |
      And I press "Log in"
    Then I should see "Welcome"
      And I should be on the homepage

  Scenario: Log in with an inactive account
    Given there is a User like the following:
        | Login                 | test             |
        | Password              | pass1234         |
        | Password Confirmation | pass1234         |
        | Email                 | test@example.com |
      And that User is not active
      And I am on the login page
    When I fill in the following:
        | Login    | test     |
        | Password | pass1234 |
      And I press "Log in"
    Then I should be on the user session page
      And I should see "not active"
      And I should not see "Welcome"

  Scenario: Forgot password
    Given I have an account called "test"
      And I am on the forgot password page
    When I fill in "login" with "test"
      And I press "Submit"
    Then I should see "Please check your email"
      And I receive an email to "test@example.com"
    When I click on the first link in the email
    Then I should be on the reset password page
    When I fill in "Password" with "pass2345"
      And I fill in "Confirm Password" with "pass2345"
      And I press "Reset Password"
    Then I should see "Your password has been changed"
      And the user "test" should have password "pass2345"

  Scenario: Password doesn't match when resetting password
    Given I have an account called "test"
      And I am on the forgot password page
    When I fill in "login" with "test"
      And I press "Submit"
      And I receive an email to "test@example.com"
      And I click on the first link in the email
      And I fill in "Password" with "pass2345"
      And I fill in "Confirm Password" with "pass2346"
      And I press "Reset Password"
    Then I should see "doesn't match"
      And I should be on the reset password page

  Scenario: Password is invalid when resetting password
    Given I have an account called "test"
      And I am on the forgot password page
    When I fill in "login" with "test"
      And I press "Submit"
      And I receive an email to "test@example.com"
      And I click on the first link in the email
      And I fill in "Password" with "pass"
      And I fill in "Confirm Password" with "pass"
      And I press "Reset Password"
    Then I should see "too short"
      And I should be on the reset password page

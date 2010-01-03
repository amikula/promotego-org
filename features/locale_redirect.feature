Feature: Locale redirect
  In order to see the correct language
  the user and search bots
  wants to be redirected to the correct locale url

  Scenario: Request the homepage as a regular user
    Given my 'Host' header is 'example.com'
    When I go to the homepage
    Then I should be on the homepage
      And I should not have been redirected

  Scenario: Request en.* as a regular user
    Given my 'Accept-Language' header is 'en'
      And my 'Host' header is 'en.example.com'
    When I work around broken redirect behavior and go to the homepage
    Then I should be on the homepage
      And I should have been redirected
      And my host should be 'example.com'

  Scenario: Request en.* as a bot
    Given my 'Accept-Language' header is 'en'
      And my 'Host' header is 'en.example.com'
      And I am a search bot
    When I go to the homepage
    Then I should be on the homepage
      And I should not have been redirected

  Scenario: Request en.* as a bot with en-US
    Given my 'Accept-Language' header is 'en-US'
      And my 'Host' header is 'en.example.com'
      And I am a search bot
    When I go to the homepage
    Then I should be on the homepage
      And I should not have been redirected

  Scenario: Request ja.* as a bot with en-US
    Given my 'Accept-Language' header is 'en-US'
      And my 'Host' header is 'ja.example.com'
      And I am a search bot
    When I go to the homepage
    Then I should be on the homepage
      And I should not have been redirected

  Scenario: Request the default hostname as a bot with en-US
    Given my 'Accept-Language' header is 'en-US'
      And my 'Host' header is 'example.com'
      And I am a search bot
    When I work around broken redirect behavior and go to the homepage
    Then I should be on the homepage
      And I should have been redirected
      And my host should be 'en.example.com'

  Scenario: Request the default hostname as a bot
    Given my 'Accept-Language' header is 'en'
      And my 'Host' header is 'example.com'
      And I am a search bot
    When I work around broken redirect behavior and go to the homepage
    Then I should be on the homepage
      And I should have been redirected
      And my host should be 'en.example.com'

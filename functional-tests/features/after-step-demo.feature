@after-step-demo
Feature: after-step-demo


  Scenario: user visits a few pages
    In this example we capture the page after each step

    Given a user navigates to http://www.google.com
    And a user navigates to http://www.bing.com
    And a user navigates to http://www.yahoo.com
    And a user navigates to http://www.duckduckgo.com
    And a user navigates to http://www.ask.com


  Scenario: user visits wikipedia
    And a user navigates to http://www.wikipedia.org

  Scenario: user visits wikipedia again
    And a user navigates to http://www.wikipedia.org

  Scenario: user visits wolframalpha
    And a user navigates to http://www.wolframalpha.com
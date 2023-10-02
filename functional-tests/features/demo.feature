Feature: demo

  @after-step-demo
  Scenario: user visits one page per step
    In this example we capture the page after each step

    Given a user navigates to http://www.google.com
    And a user navigates to http://www.bing.com
    And a user navigates to http://www.yahoo.com
    And a user navigates to http://www.duckduckgo.com
    And a user navigates to http://www.ask.com
    And a user navigates to http://www.wolframalpha.com
    And a user navigates to http://www.wikipedia.org
    And a user navigates to http://www.wolframalpha.com

  @loop-demo
  Scenario: a user navigates a gov.uk flow
      In this example we use a loop to navigate and capture the page each iteration of the loop

    Given a user navigates through https://en.wikipedia.org/wiki/String_theory



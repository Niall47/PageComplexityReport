Feature: loop-demo

  @loop-demo
  Scenario: a user navigates a gov.uk flow
  In this example we use a loop to navigate and capture the page each iteration of the loop

    Given a user navigates through https://en.wikipedia.org/wiki/String_theory

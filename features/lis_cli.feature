Feature: My bootstrapped app kinda works

  Scenario: App just runs
    When I get help for "lis2http"
    Then the exit status should be 0


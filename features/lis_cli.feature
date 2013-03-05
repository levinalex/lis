Feature: My bootstrapped app kinda works

  Scenario: App just runs
    When I get help for "lis"
    Then the exit status should be 1


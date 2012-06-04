Feature: cli/version



  Scenario: Getting the version
    When I run `librarian-chef version`
    Then the exit status should be 0
    And the output should contain "librarian-"




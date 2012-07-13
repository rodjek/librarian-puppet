Feature: cli/init



  Scenario: Initing a directory
    When I run `librarian-chef init`
    Then the exit status should be 0
    Then a file named "Cheffile" should exist




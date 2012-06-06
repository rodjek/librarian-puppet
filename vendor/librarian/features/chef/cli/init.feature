Feature: cli/init



  Scenario: Initing a directory
    When I run `librarian-chef init`
    Then a file named "Cheffile" should exist




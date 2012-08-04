Feature: displays help if no subcommand is passed
  In order to get started using librarian-puppet
  A user should be able to run librarian-puppet without any subcommands or options
  Then the exit status should be 0
  And a useful help screen should be displayed

  Scenario: App defaults to help subcommand
    When I run `librarian-puppet`
    Then the exit status should be 0
    And the output should contain "librarian-puppet version"

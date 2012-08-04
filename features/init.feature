Feature: init subcommand should generate a Puppetfile
  In order to start using librarian-puppet in a project
  A project will need a Puppetfile.
  If a user runs "librarian-puppet init"
  Then the exit status should be 0
  And a file named "Puppetfile" should exist


  Scenario: init subcommand should generate a Puppetfile
    When I run `librarian-puppet init`
    Then the exit status should be 0
    Then a file named "Puppetfile" should exist

Feature: cli/install
  In order to be worth anything
  Puppet librarian needs to install modules properly

  Scenario: Running install with no Puppetfile
    Given there is no Puppetfile
    When I run `librarian-puppet install`
    Then the output should contain "Could not find Puppetfile"
    And the exit status should be 1

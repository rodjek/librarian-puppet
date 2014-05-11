Feature: cli/install
  In order to be worth anything
  Puppet librarian needs to install modules properly

  Scenario: Running install with no Puppetfile
    Given there is no Puppetfile
    When I run `librarian-puppet install`
    Then the output should contain "Could not find Puppetfile"
    And the exit status should be 1

  Scenario: Install a module dependency from git and forge should be deterministic
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/stdlib', :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git', :ref => '3.0.0'
    mod 'librarian/test', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/test'
    """
    When I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the file "modules/stdlib/Modulefile" should match /version *'3\.0\.0'/
    And the output should not contain "Executing puppet module install for puppetlabs/stdlib"

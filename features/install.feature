Feature: cli/install
  In order to be worth anything
  Puppet librarian needs to install modules properly

  Scenario: Running install with no Puppetfile nor metadata.json
    Given there is no Puppetfile
    When I run `librarian-puppet install`
    Then the output should match /^Metadata file does not exist: .*metadata.json$/
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
    And the output should not contain "Executing puppet module install for puppetlabs-stdlib"

  Scenario: Install a module with Modulefile without version
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'librarian-bad_modulefile', :path => 'bad_modulefile'
    """
    And a directory named "bad_modulefile/manifests"
    And a file named "bad_modulefile/Modulefile" with:
    """
    # bad Modulefile
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the output should match:
    """
    Unable to parse .*/bad_modulefile/Modulefile, ignoring: Missing version
    """

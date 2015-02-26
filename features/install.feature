Feature: cli/install
  In order to be worth anything
  Puppet librarian needs to install modules properly

  Scenario: Running install with no Puppetfile nor metadata.json
    Given there is no Puppetfile
    When I run `librarian-puppet install`
    Then the output should match /^Metadata file does not exist: .*metadata.json$/
    And the exit status should be 1

  Scenario: Running install with bad metadata.json
    Given a file named "metadata.json" with:
    """
    """
    When I run `librarian-puppet install`
    Then the output should match /^Unable to parse json file .*metadata.json: .*$/
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

  Scenario: Installing two modules with same name and using exclusions
    Given a file named "Puppetfile" with:
    """
    forge "https://forgeapi.puppetlabs.com"

    mod 'librarian-duplicated_dependencies', :path => '../../features/examples/duplicated_dependencies'
    exclusion 'ripienaar-concat'
    """
    When I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the file "modules/concat/metadata.json" should match /"name": "puppetlabs-concat"/
    And the output should contain "Excluding dependency ripienaar-concat from"

  Scenario: Installing two modules with same name and using exclusions, apply transitively
    Given a file named "Puppetfile" with:
    """
    forge "https://forgeapi.puppetlabs.com"

    mod 'librarian-duplicated_dependencies_transitive', :path => '../../features/examples/duplicated_dependencies_transitive'
    """
    When PENDING I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the file "modules/concat/metadata.json" should match /"name": "puppetlabs-concat"/

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

    Scenario: Install a module with the rsync configuration using the --clean flag
      Given a file named "Puppetfile" with:
      """
      forge "http://forge.puppetlabs.com"

      mod 'maestrodev/test'
      """
      And a file named ".librarian/puppet/config" with:
      """
      ---
      LIBRARIAN_PUPPET_RSYNC: 'true'
      """
      When I run `librarian-puppet config`
      Then the exit status should be 0
      And the output should contain "rsync: true"
      When I run `librarian-puppet install`
      Then the exit status should be 0
      And a directory named "modules/test" should exist
      And the file "modules/test" should have an inode and ctime
      When I run `librarian-puppet install --clean`
      Then the exit status should be 0
      And a directory named "modules/test" should exist
      And the file "modules/test" should not have the same inode or ctime as before

    Scenario: Install a module with the rsync configuration using the --destructive flag
      Given a file named "Puppetfile" with:
      """
      forge "http://forge.puppetlabs.com"

      mod 'maestrodev/test'
      """
      And a file named ".librarian/puppet/config" with:
      """
      ---
      LIBRARIAN_PUPPET_RSYNC: 'true'
      """
      When I run `librarian-puppet config`
      Then the exit status should be 0
      And the output should contain "rsync: true"
      When I run `librarian-puppet install`
      Then the exit status should be 0
      And a directory named "modules/test" should exist
      And the file "modules/test" should have an inode and ctime
      Given I wait for 1 second
      When I run `librarian-puppet install --destructive`
      Then the exit status should be 0
      And a directory named "modules/test" should exist
      And the file "modules/test" should not have the same inode or ctime as before

    Scenario: Install a module with the rsync configuration
      Given a file named "Puppetfile" with:
      """
      forge "http://forge.puppetlabs.com"

      mod 'maestrodev/test'
      """
      And a file named ".librarian/puppet/config" with:
      """
      ---
      LIBRARIAN_PUPPET_RSYNC: 'true'
      """
      When I run `librarian-puppet config`
      Then the exit status should be 0
      And the output should contain "rsync: true"
      When I run `librarian-puppet install`
      Then the exit status should be 0
      And a directory named "modules/test" should exist
      And the file "modules/test" should have an inode and ctime
      Given I wait for 1 second
      When I run `librarian-puppet install`
      Then the exit status should be 0
      And a directory named "modules/test" should exist
      And the file "modules/test" should have the same inode and ctime as before

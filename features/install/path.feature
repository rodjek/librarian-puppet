Feature: cli/install/path
  Puppet librarian needs to install modules from local paths

  Scenario: Install a module with dependencies specified in a Puppetfile
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/with_puppetfile', :path => '../../features/examples/with_puppetfile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'librarian-with_puppetfile'/
    And the file "modules/test/Modulefile" should match /name *'librarian-test'/

  Scenario: Install a module with dependencies specified in a Puppetfile and Modulefile
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/with_puppetfile', :path => '../../features/examples/with_puppetfile_and_modulefile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'librarian-with_puppetfile_and_modulefile'/
    And the file "modules/test/Modulefile" should match /name *'maestrodev-test'/

  Scenario: Install a module from path without version
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'test', :path => '../../features/examples/dependency_without_version'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/test/Modulefile" should match /version *'0\.0\.1'/
    And a file named "modules/stdlib/Modulefile" should exist

  @spaces
  Scenario: Installing a module in a path with spaces
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/test', :path => '../../features/examples/test'
    mod 'puppetlabs/stdlib', :git => 'https://github.com/puppetlabs/puppetlabs-stdlib'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/test/Modulefile" should match /name *'librarian-test'/

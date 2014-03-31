Feature: cli/install/path
  Puppet librarian needs to install modules from local paths

  @slow
  Scenario: Install a module with dependencies specified in a Puppetfile
    Given a file named "Puppetfile" with:
    """
    mod 'with_puppetfile', :path => '../../features/examples/with_puppetfile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'with-puppetfile'/
    And the file "modules/test/Modulefile" should match /name *'librarian-test'/

  @slow
  @announce
  Scenario: Install a module with dependencies specified in a Puppetfile and Modulefile
    Given a file named "Puppetfile" with:
    """
    mod 'with_puppetfile', :path => '../../features/examples/with_puppetfile_and_modulefile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'with-puppetfile-and-modulefile'/
    And the file "modules/test/Modulefile" should match /name *'maestrodev-test'/
    And the file "modules/test/Modulefile" should match /version *'1\.0\.8'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/
    And the file "modules/stdlib/Modulefile" should match /version *'3\.2\.1'/
    And the file "modules/concat/Modulefile" should match /name *'puppetlabs-concat'/
    And the file "modules/concat/Modulefile" should match /version *'1\.0\.2'/

  @veryslow
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

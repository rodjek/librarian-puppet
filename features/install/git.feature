Feature: cli/install/git
  Puppet librarian needs to install modules from git repositories

  @veryslow
  Scenario: Installing a module from git 
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apache',
        :git => 'https://github.com/puppetlabs/puppetlabs-apache.git', :ref => '0.6.0'

    mod 'puppetlabs/stdlib',
        :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git', :ref => 'v2.2.1'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apache/Modulefile" should match /name *'puppetlabs-apache'/
    And the file "modules/apache/Modulefile" should match /version *'0\.6\.0'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/
    And the file "modules/stdlib/Modulefile" should match /version *'2\.2\.1'/

  @slow
  Scenario: Installing a module with invalid versions in git
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod "apache",
      :git => "https://github.com/puppetlabs/puppetlabs-apache.git", :ref => "0.5.0-rc1"
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apache/Modulefile" should match /name *'puppetlabs-apache'/
    And the file "modules/apache/Modulefile" should match /version *'0\.5\.0-rc1'/

  @veryslow
  Scenario: Switching a module from forge to git
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql', '1.0.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version *'1\.0\.0'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/
    When I overwrite "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql',
      :git => 'https://github.com/puppetlabs/puppet-postgresql.git', :ref => '1.0.0'
    """
    And I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version *'1\.0\.0'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @slow
  Scenario: Install a module with dependencies specified in a Puppetfile
    Given a file named "Puppetfile" with:
    """
    mod 'with_puppetfile', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/with_puppetfile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'with-puppetfile'/
    And the file "modules/test/Modulefile" should match /name *'librarian-test'/

  @slow
  Scenario: Install a module with dependencies specified in a Puppetfile and Modulefile
    Given a file named "Puppetfile" with:
    """
    mod 'with_puppetfile', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/with_puppetfile_and_modulefile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'with-puppetfile-and-modulefile'/
    And the file "modules/test/Modulefile" should match /name *'maestrodev-test'/

  @veryslow
  Scenario: Install a module from git and using path
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'test', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/test'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/test/Modulefile" should match /version *'0\.0\.1'/
    And a file named "modules/stdlib/Modulefile" should exist

  @veryslow
  Scenario: Install a module from git without version
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'test', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/dependency_without_version'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/test/Modulefile" should match /version *'0\.0\.1'/
    And a file named "modules/stdlib/Modulefile" should exist

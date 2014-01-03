Feature: cli/install
  In order to be worth anything
  Puppet librarian needs to install modules properly

  Scenario: Running install with no Puppetfile
    Given there is no Puppetfile
    When I run `librarian-puppet install`
    Then the output should contain "Could not find Puppetfile"
    And the exit status should be 1

  @veryslow
  Scenario: Installing a module and its dependencies
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @veryveryslow
  Scenario: Installing an exact version of a module
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '0.0.4'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/apt/Modulefile" should match /version *'0\.0\.4'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @veryslow
  Scenario: Installing a module with invalid versions in the forge
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apache', '0.4.0'
    mod 'puppetlabs/postgresql', '2.0.1'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apache/Modulefile" should match /name *'puppetlabs-apache'/
    And the file "modules/apache/Modulefile" should match /version *'0\.4\.0'/
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version *'2\.0\.1'/

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

  @slow
  Scenario: Installing a module with several constraints
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '>=1.0.0', '<1.0.1'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/apt/Modulefile" should match /version *'1\.0\.0'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

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
  Scenario: Changing the path
    Given a directory named "puppet"
    And a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt'
    """
    When I run `librarian-puppet install --path puppet/modules`
    And I run `librarian-puppet config`
    Then the exit status should be 0
    And the output from "librarian-puppet config" should contain "path: puppet/modules"
    And the file "puppet/modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "puppet/modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @veryslow
  Scenario: Handle range version numbers
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/

    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql', :git => 'git://github.com/puppetlabs/puppet-postgresql'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/

  Scenario: Installing a module that does not exist
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/xxxxx'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 1
    And the output should contain "Unable to find module 'puppetlabs/xxxxx' on http://forge.puppetlabs.com"

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

  Scenario: Install a module with conflicts
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apache', '0.6.0'
    mod 'puppetlabs/stdlib', '<2.2.1'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 1
    And the output should contain "Could not resolve the dependencies"

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

  @slow
  Scenario: Install a module from the Forge with dependencies without version
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'sbadia/gitlab', '0.1.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/gitlab/Modulefile" should match /version *'0\.1\.0'/

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

  @veryslow
  Scenario: Source dependencies from Modulefile
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    modulefile
    """
    And a file named "Modulefile" with:
    """
    name "random name"
    dependency "puppetlabs/postgresql", "2.4.1"
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/

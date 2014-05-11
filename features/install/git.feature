Feature: cli/install/git
  Puppet librarian needs to install modules from git repositories

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
    And the file "modules/apache/.git/HEAD" should match /b18fad908fe7cb8fbc6604fde1962c85540095f4/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/
    And the file "modules/stdlib/Modulefile" should match /version *'2\.2\.1'/
    And the file "modules/stdlib/.git/HEAD" should match /a70b09d5de035de5254ebe6ad6e1519a6d7cf588/

  @spaces
  Scenario: Installing a module in a path with spaces
    Given a file named "Puppetfile" with:
    """
    mod 'puppetlabs/stdlib', '4.1.0', :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git', :ref => '4.1.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

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
      :git => 'https://github.com/puppetlabs/puppetlabs-postgresql.git', :ref => '1.0.0'
    """
    And I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version *'1\.0\.0'/
    And the file "modules/postgresql/.git/HEAD" should match /183d401a3ffeb2e83372dfcc05f5b6bab25034b1/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  Scenario: Install a module with dependencies specified in a Puppetfile
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/with_puppetfile', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/with_puppetfile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'librarian-with_puppetfile'/
    And the file "modules/test/Modulefile" should match /name *'librarian-test'/

  Scenario: Install a module with dependencies specified in a Puppetfile and Modulefile
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/with_puppetfile', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/with_puppetfile_and_modulefile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'librarian-with_puppetfile_and_modulefile'/
    And the file "modules/test/Modulefile" should match /name *'maestrodev-test'/

  Scenario: Install a module using modulefile syntax
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/modulefile_syntax', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/modulefile_syntax'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/modulefile_syntax/Modulefile" should match /name *'librarian-modulefile_syntax'/
    And the file "modules/test/Modulefile" should match /name *'maestrodev-test'/

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

  @announce
  Scenario: Install a module with mismatching Puppetfile and Modulefile
    Given a file named "Puppetfile" with:
    """
    mod 'duritong/munin', :git => 'https://github.com/2ndquadrant-it/puppet-munin.git', :ref => '0bb71e'
    """
    When PENDING I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the file "modules/munin/Modulefile" should match /name *'duritong-munin'/
    And the file "modules/concat/Modulefile" should match /name *'puppetlabs-concat'/

  @announce
  Scenario: Install from Puppetfile with duplicated entries
    Given a file named "Puppetfile" with:
    """
    mod 'stdlib',
      :git => 'git://github.com/puppetlabs/puppetlabs-stdlib.git'

    mod 'stdlib',
      :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git'
    """
    When PENDING I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

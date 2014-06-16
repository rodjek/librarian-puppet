Feature: cli/install/forge
  Puppet librarian needs to install modules from the Puppet Forge

  Scenario: Installing a module and its dependencies
    Given a file named "Puppetfile" with:
    """
    forge "https://forgeapi.puppetlabs.com"

    mod 'puppetlabs/ntp'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/ntp/metadata.json" should match /"name": "puppetlabs-ntp"/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

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

  # Puppet Module tool does not support spaces
  # https://github.com/rodjek/librarian-puppet/issues/201
  # https://tickets.puppetlabs.com/browse/PUP-2278
  @spaces
  Scenario: Installing a module in a path with spaces
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"
    mod 'puppetlabs/stdlib', '4.1.0'
    """
    When PENDING I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  Scenario: Installing a module with invalid versions in the forge
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apache', '0.4.0'
    mod 'puppetlabs/postgresql', '2.0.1'
    mod 'puppetlabs/apt', '< 1.4.2' # 1.4.2 causes trouble in travis
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apache/Modulefile" should match /name *'puppetlabs-apache'/
    And the file "modules/apache/Modulefile" should match /version *'0\.4\.0'/
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version *'2\.0\.1'/

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

  Scenario: Changing the path
    Given a directory named "puppet"
    And a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/ntp', '3.0.3'
    """
    When I run `librarian-puppet install --path puppet/modules`
    And I run `librarian-puppet config`
    Then the exit status should be 0
    And the output from "librarian-puppet config" should contain "path: puppet/modules"
    And the file "puppet/modules/ntp/Modulefile" should match /name *'puppetlabs-ntp'/
    And the file "puppet/modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  Scenario: Handle range version numbers
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql', '3.2.0'
    mod 'puppetlabs/apt', '< 1.4.2' # 1.4.2 causes trouble in travis
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name 'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version '3\.2\.0'/

    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql', :git => 'git://github.com/puppetlabs/puppet-postgresql', :ref => '3.3.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name 'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version '3\.3\.0'/

  Scenario: Installing a module that does not exist
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/xxxxx'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 1
    And the output should match:
      """
      Unable to find module 'puppetlabs/xxxxx' on http(s)?://forge(api)?.puppetlabs.com
      """

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

  Scenario: Install a module from the Forge with dependencies without version
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'sbadia/gitlab', '0.1.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/gitlab/Modulefile" should match /version *'0\.1\.0'/

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

  Scenario: Installing a module with duplicated dependencies
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'pdxcat/collectd', '2.1.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/collectd/Modulefile" should match /name *'pdxcat-collectd'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

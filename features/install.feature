Feature: cli/install
  In order to be worth anything
  Puppet librarian needs to install modules properly

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
  Scenario: Install a module with dependencies specified in a Puppetfile
    Given a file named "Puppetfile" with:
    """
    mod 'super', :git => 'git://github.com/mpalmer/puppet-super'
    
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/super/Puppetfile" should match /mod *'sub'/
    And the file "Puppetfile.lock" should match /remote: git:..github\.com.mpalmer.puppet-sub/

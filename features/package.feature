Feature: cli/package
  Puppet librarian needs to package modules

  Scenario: Packaging a module and its dependencies
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '1.4.0'
    """
    When I run `librarian-puppet package --verbose`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/
    And the following files should exist:
      | vendor/puppet/cache/puppetlabs-apt-1.4.0.tar.gz    |
      | vendor/puppet/cache/puppetlabs-stdlib-4.1.0.tar.gz |

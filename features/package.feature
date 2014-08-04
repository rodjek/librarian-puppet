Feature: cli/package
  Puppet librarian needs to package modules

  Scenario: Packaging a forge module
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '1.4.0'
    mod 'puppetlabs/stdlib', '4.1.0'
    """
    When I run `librarian-puppet package --verbose`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/
    And the following files should exist:
      | vendor/puppet/cache/puppetlabs-apt-1.4.0.tar.gz    |
      | vendor/puppet/cache/puppetlabs-stdlib-4.1.0.tar.gz |

  Scenario: Packaging a git module
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '1.5.0', :git => 'https://github.com/puppetlabs/puppetlabs-apt.git', :ref => '1.5.0'
    mod 'puppetlabs/stdlib', '4.1.0'
    """
    When I run `librarian-puppet package --verbose`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/
    And the following files should exist:
      | vendor/puppet/source/e5657a61b9ac0dd3c00002c777b0d3c615bb98a5.tar.gz |
      | vendor/puppet/cache/puppetlabs-stdlib-4.1.0.tar.gz                   |

  @github
  Scenario: Packaging a github tarball module
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '1.4.0', :github_tarball => 'puppetlabs/puppetlabs-apt'
    mod 'puppetlabs/stdlib', '4.1.0'
    """
    When I run `librarian-puppet package --verbose`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/
    And the following files should exist:
      | vendor/puppet/cache/puppetlabs-puppetlabs-apt-1.4.0.tar.gz |
      | vendor/puppet/cache/puppetlabs-stdlib-4.1.0.tar.gz         |

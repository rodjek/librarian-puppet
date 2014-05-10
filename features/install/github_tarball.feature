Feature: cli/install/github_tarball
  Puppet librarian needs to install tarballed modules from github repositories

  @github
  Scenario: Installing a module from github tarballs
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apache', '0.6.0', :github_tarball => 'puppetlabs/puppetlabs-apache'
    mod 'puppetlabs/stdlib', '2.3.0', :github_tarball => 'puppetlabs/puppetlabs-stdlib'
    """
    When I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the output should contain "Downloading <https://api.github.com/repos/puppetlabs/puppetlabs-apache/tarball/0.6.0"
    And the output should contain "Downloading <https://api.github.com/repos/puppetlabs/puppetlabs-stdlib/tarball/2.3.0"
    And the file "modules/apache/Modulefile" should match /name *'puppetlabs-apache'/
    And the file "modules/apache/Modulefile" should match /version *'0\.6\.0'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/
    And the file "modules/stdlib/Modulefile" should match /version *'2\.3\.0'/

  @spaces
  @github
  Scenario: Installing a module in a path with spaces
    Given a file named "Puppetfile" with:
    """
    mod 'puppetlabs/stdlib', '4.1.0', :github_tarball => 'puppetlabs/puppetlabs-stdlib'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

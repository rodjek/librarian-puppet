Feature: cli/update
  Puppet librarian needs to update modules properly

  Scenario: Updating a module
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/stdlib', '3.1.x'
    """
    And a file named "Puppetfile.lock" with:
    """
    FORGE
      remote: http://forge.puppetlabs.com
      specs:
        puppetlabs/stdlib (3.1.0)

    DEPENDENCIES
      puppetlabs/stdlib (~> 3.0)
    """
    When I run `librarian-puppet update puppetlabs/stdlib`
    Then the exit status should be 0
    And the file "Puppetfile.lock" should match /puppetlabs.stdlib \(3\.1\.1\)/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/
    And the file "modules/stdlib/Modulefile" should match /version *'3\.1\.1'/

  @slow
  Scenario: Updating a module with invalid versions in git
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod "apache",
      :git => "https://github.com/puppetlabs/puppetlabs-apache.git", :ref => "0.5.0-rc1"
    """
    And a file named "Puppetfile.lock" with:
    """
    FORGE
      remote: http://forge.puppetlabs.com
      specs:
        puppetlabs/firewall (0.0.4)
        puppetlabs/stdlib (3.2.0)

    GIT
      remote: https://github.com/puppetlabs/puppetlabs-apache.git
      ref: 0.5.0-rc1
      sha: 94ebca3aaaf2144a7b9ce7ca6a13837ec48a7e2a
      specs:
        apache ()
          puppetlabs/firewall (>= 0.0.4)
          puppetlabs/stdlib (>= 2.2.1)

    DEPENDENCIES
      apache (>= 0)
    """
    When I run `librarian-puppet update apache`
    Then the exit status should be 0
    And the file "Puppetfile.lock" should match /sha: d81999533af54a6fe510575d3b143308184a5005/
    And the file "modules/apache/Modulefile" should match /name *'puppetlabs-apache'/
    And the file "modules/apache/Modulefile" should match /version *'0\.5\.0-rc1'/

  Scenario: Updating a module that is not in the Puppetfile
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/stdlib', '3.1.x'
    """
    And a file named "Puppetfile.lock" with:
    """
    FORGE
      remote: http://forge.puppetlabs.com
      specs:
        puppetlabs/stdlib (3.1.0)

    DEPENDENCIES
      puppetlabs/stdlib (~> 3.0)
    """
    When I run `librarian-puppet update stdlib`
    Then the exit status should be 1
    And the output should contain "Unable to find module stdlib"

  Scenario: Updating a module to a .10 release to ensure versions are correctly ordered
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'maestrodev/test'
    """
    And a file named "Puppetfile.lock" with:
    """
    FORGE
      remote: http://forge.puppetlabs.com
      specs:
        maestrodev/test (1.0.2)

    DEPENDENCIES
      maestrodev/test (>= 0)
    """
    When I run `librarian-puppet update --verbose`
    Then the exit status should be 0
    And the file "Puppetfile.lock" should contain "maestrodev/test (1.0.10)"
    And the file "modules/test/Modulefile" should contain "name 'maestrodev-test'"
    And the file "modules/test/Modulefile" should contain "version '1.0.10'"

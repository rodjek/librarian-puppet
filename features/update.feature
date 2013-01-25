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

Feature: cli/outdated
  Puppet librarian needs to print outdated modules

  Scenario: Running outdated with forge modules
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/stdlib', '>=3.1.x'
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
    When I run `librarian-puppet outdated`
    Then the exit status should be 0
    And the output should match:
    """
    ^puppetlabs/stdlib \(3\.1\.0 -> [\.\d]+\)$
    """

  Scenario: Running outdated with git modules
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'test', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/test'
    """
    And a file named "Puppetfile.lock" with:
    """
    FORGE
      remote: http://forge.puppetlabs.com
      specs:
        puppetlabs/stdlib (3.1.0)

    GIT
      remote: https://github.com/rodjek/librarian-puppet.git
      path: features/examples/test
      ref: master
      sha: 517beed403cfe3b2b61598975d8cecd27c665add
      specs:
        test (0.0.1)
          puppetlabs/stdlib (>= 0)

    DEPENDENCIES
      test (>= 0)
    """
    When I run `librarian-puppet outdated`
    Then the exit status should be 0
    And PENDING the output should match:
    # """
    # ^puppetlabs/stdlib \(3\.1\.0 -> [\.\d]+\)$
    # ^test .*$
    # """

Feature: cli/show



  Background: A simple Cheffile with one cookbook with one dependency
    Given a file named "cookbook-sources/main/metadata.yaml" with:
      """
      name: main
      version: 1.0.0
      dependencies:
        sub: 1.0.0
      """
    Given a file named "cookbook-sources/sub/metadata.yaml" with:
      """
      name: sub
      version: 1.0.0
      dependencies: {}
      """
    Given a file named "Cheffile" with:
      """
      path 'cookbook-sources'
      cookbook 'main'
      """
    Given I run `librarian-chef install --quiet`



  Scenario: Showing al without a lockfile
    Given I remove the file "Cheffile.lock"
    When  I run `librarian-chef show`
    Then  the exit status should be 1
    Then  the output should contain exactly:
      """
      Be sure to install first!

      """



  Scenario: Showing all
    When I run `librarian-chef show`
    Then the exit status should be 0
    Then the output should contain exactly:
      """
      main (1.0.0)
      sub (1.0.0)

      """



  Scenario: Showing one without dependencies
    When I run `librarian-chef show sub`
    Then the exit status should be 0
    Then the output should contain exactly:
      """
      sub (1.0.0)
        source: cookbook-sources

      """



  Scenario: Showing one with dependencies
    When I run `librarian-chef show main`
    Then the exit status should be 0
    Then the output should contain exactly:
      """
      main (1.0.0)
        source: cookbook-sources
        dependencies:
          sub (= 1.0.0)

      """




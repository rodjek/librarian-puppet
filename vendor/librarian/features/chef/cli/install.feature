Feature: cli/install



  Scenario: A simple Cheffile with one cookbook
    Given a file named "cookbook-sources/apt/metadata.yaml" with:
      """
      name: apt
      version: 1.0.0
      dependencies: { }
      """
    Given a file named "Cheffile" with:
      """
      cookbook 'apt',
        :path => 'cookbook-sources'
      """
    When I run `librarian-chef install --verbose`
    Then the exit status should be 0
    And the file "cookbooks/apt/metadata.yaml" should contain exactly:
      """
      name: apt
      version: 1.0.0
      dependencies: { }
      """



  Scenario: A simple Cheffile with one cookbook with one dependency
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
    When I run `librarian-chef install --verbose`
    Then the exit status should be 0
    And the file "cookbooks/main/metadata.yaml" should contain exactly:
      """
      name: main
      version: 1.0.0
      dependencies:
        sub: 1.0.0
      """
    And the file "cookbooks/sub/metadata.yaml" should contain exactly:
      """
      name: sub
      version: 1.0.0
      dependencies: {}
      """




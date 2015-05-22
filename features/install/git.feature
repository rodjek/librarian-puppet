Feature: cli/install/git
  Puppet librarian needs to install modules from git repositories

  Scenario: Installing a module from git 
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apache',
        :git => 'https://github.com/puppetlabs/puppetlabs-apache.git', :ref => '1.4.0'

    mod 'puppetlabs/stdlib',
        :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git', :ref => '4.6.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apache/metadata.json" should match /"name": "puppetlabs-apache"/
    And the file "modules/apache/metadata.json" should match /"version": "1\.4\.0"/
    And the git revision of module "apache" should be "e4ec6d4985fdb23e26c809e0d5786823d0689f90"
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/
    And the file "modules/stdlib/metadata.json" should match /"version": "4\.6\.0"/
    And the git revision of module "stdlib" should be "73474b00b5ae3cbccec6cd0711311d6450139e51"

  @spaces
  Scenario: Installing a module in a path with spaces
    Given a file named "Puppetfile" with:
    """
    mod 'puppetlabs/stdlib', '4.6.0', :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git', :ref => '4.6.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/

  Scenario: Installing a module with invalid versions in git
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod "apache",
      :git => "https://github.com/puppetlabs/puppetlabs-apache.git", :ref => "1.4.0"
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apache/metadata.json" should match /"name": "puppetlabs-apache"/
    And the file "modules/apache/metadata.json" should match /"version": "1\.4\.0"/

  Scenario: Switching a module from forge to git
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql', '4.0.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/metadata.json" should match /"name": "puppetlabs-postgresql"/
    And the file "modules/postgresql/metadata.json" should match /"version": "4\.0\.0"/
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/
    When I overwrite "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql',
      :git => 'https://github.com/puppetlabs/puppetlabs-postgresql.git', :ref => '4.3.0'
    """
    And I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/postgresql/metadata.json" should match /"name": "puppetlabs-postgresql"/
    And the file "modules/postgresql/metadata.json" should match /"version": "4\.3\.0"/
    And the file "modules/postgresql/.git/HEAD" should match /9ca4b42450ea9c9ed8eec52dac48cb67187ae925/
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/

  Scenario: Install a module with dependencies specified in metadata.json
    Given a file named "Puppetfile" with:
    """
    mod 'puppetlabs-apt', :git => 'https://github.com/puppetlabs/puppetlabs-apt.git', :ref => '1.5.2'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/stdlib/metadata.json" should match /"name": "puppetlabs-stdlib"/
    And the file "modules/apt/metadata.json" should match /"name": "puppetlabs-apt"/

  Scenario: Install a module with dependencies specified in a Puppetfile
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/with_puppetfile', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/with_puppetfile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/metadata.json" should match /"name": "librarian-with_puppetfile"/
    And the file "modules/test/metadata.json" should match /"name": "librarian-test"/

  @puppet2 @puppet3
  Scenario: Install a module with dependencies specified in a Puppetfile and Modulefile
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/with_puppetfile', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/with_puppetfile_and_modulefile'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/Modulefile" should match /name *'librarian-with_puppetfile_and_modulefile'/
    And the file "modules/test/Modulefile" should match /name *'maestrodev-test'/

  Scenario: Install a module with dependencies specified in a Puppetfile and metadata.json
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/with_puppetfile', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/with_puppetfile_and_metadata_json'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/with_puppetfile/metadata.json" should match /"name": "librarian-with_puppetfile_and_metadata_json"/
    And the file "modules/test/metadata.json" should match /"name": "maestrodev-test"/

  Scenario: Running install with no Modulefile nor metadata.json
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/stdlib', :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git', :ref => '4.6.0'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0

  Scenario: Running install with metadata.json without dependencies
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/sqlite', :git => 'https://github.com/puppetlabs/puppetlabs-sqlite.git', :ref => '84a0a6'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0

  @puppet2 @puppet3
  Scenario: Install a module using modulefile syntax
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/modulefile_syntax', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/modulefile_syntax'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/modulefile_syntax/Modulefile" should match /name *'librarian-modulefile_syntax'/
    And the file "modules/test/Modulefile" should match /name *'maestrodev-test'/

  Scenario: Install a module using metadata syntax
    Given a file named "Puppetfile" with:
    """
    mod 'librarian/metadata_syntax', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/metadata_syntax'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/metadata_syntax/metadata.json" should match /"name": "librarian-metadata_syntax"/
    And the file "modules/test/metadata.json" should match /"name": "maestrodev-test"/

  Scenario: Install a module from git and using path
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'librarian-test', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/test'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/test/metadata.json" should match /"version": "0\.0\.1"/
    And a file named "modules/stdlib/metadata.json" should exist

  Scenario: Install a module from git without version
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'test', :git => 'https://github.com/rodjek/librarian-puppet.git', :path => 'features/examples/dependency_without_version'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/test/metadata.json" should match /"version": "0\.0\.1"/
    And a file named "modules/stdlib/metadata.json" should exist

  @puppet2 @puppet3
  Scenario: Install a module with mismatching Puppetfile and Modulefile
    Given a file named "Puppetfile" with:
    """
    mod 'duritong/munin', :git => 'https://github.com/duritong/puppet-munin.git', :ref => '0bb71e'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/munin/Modulefile" should match /name *'duritong-munin'/
    And the file "modules/concat/metadata.json" should match /"name": *"puppetlabs-concat"/
    And a file named "modules/stdlib/metadata.json" should exist

  Scenario: Install from Puppetfile with duplicated entries
    Given a file named "Puppetfile" with:
    """
    mod 'puppetlabs-stdlib',
      :git => 'git://github.com/puppetlabs/puppetlabs-stdlib.git'

    mod 'puppetlabs-stdlib',
      :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the output should contain "Dependency 'puppetlabs-stdlib' duplicated for module, merging"

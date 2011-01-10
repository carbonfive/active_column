Feature: Keyspace management
  In order to use cassandra in a Rails app
  As a Rails developer
  I want to be able to run various Rake tasks to manage my keyspace

  Scenario: Create a development keyspace
    Given a Rails app using cassandra and active column
    When I run "rake ks:create"
    Then a keyspace is created for the development environment

  Scenario: Create a keyspace for each environment
    Given a Rails app using cassandra and active column
    When I run "rake ks:create:all"
    Then a keyspace is created for each environment

  Scenario: Drop the development keyspace
    Given a Rails app using cassandra and active column
    When I run "rake ks:create"
    Then a keyspace is created for the development environment
    When I run "rake ks:drop"
    Then the development keyspace is dropped

  Scenario: Drop the keyspace for each environment
    Given a Rails app using cassandra and active column
    When I run "rake ks:create:all"
    Then a keyspace is created for each environment
    When I run "rake ks:drop:all"
    Then the keyspace is dropped for each environment

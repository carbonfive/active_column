Feature: Rails Generator
  In order to development my application's keyspace
  As a Rails developer
  I want to be able to run a generator to create a cassandra migration

  Scenario: Create a migration
    Given a Rails app using cassandra and active column
    When I run "rails g active_column:migration CreatePostsByUsers"
    Then a new migration is created

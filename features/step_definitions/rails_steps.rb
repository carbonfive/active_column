Given /^a Rails app using cassandra and active column$/ do
  steps %q{
    When I run "rails new sample-app"
      And I cd to "sample-app"
      And I append to "Gemfile" with:
        """
        gem 'cassandra',
          :require => 'cassandra/0.7'
        gem 'active_column',
          :path => './../../../'
        """
      And I run "bundle install --local"
      And a file named "config/cassandra.yml" with:
        """
        development:
          servers: 127.0.0.1:9160
          keyspace: sample_app_development
        test:
          servers: 127.0.0.1:9160
          keyspace: sample_app_test
        """
      And a file named "config/initializers/cassandra.rb" with:
        """
        config = YAML.load_file(Rails.root.join('config', 'cassandra.yml'))[Rails.env]
        $cassandra = Cassandra.new(config['keyspace'], config['servers'])
        ActiveColumn.connection = $cassandra
        """
  }
end

Then /^a keyspace is created for the development environment$/ do
  $cassandra.keyspaces.should include('sample_app_development')
  all_stdout.should match /created keyspace: sample_app_development/i
end

Then /^a keyspace is created for each environment$/ do
  $cassandra.keyspaces.should include('sample_app_development')
  $cassandra.keyspaces.should include('sample_app_test')
  all_stdout.should match /created keyspaces: sample_app_development, sample_app_test/i
end

Then /^the development keyspace is dropped$/ do
  $cassandra.keyspaces.should_not include('sample_app_development')
  all_stdout.should match /dropped keyspace: sample_app_development/i
end

Then /^the keyspace is dropped for each environment$/ do
  $cassandra.keyspaces.should_not include('sample_app_development')
  $cassandra.keyspaces.should_not include('sample_app_test')
  all_stdout.should match /dropped keyspaces: sample_app_development, sample_app_test/i
end

Then /^a new migration is created$/ do
  cd 'ks/migrate'
  in_current_dir do
    migration = Dir['*'][0]
    migration.should match(/create_posts_by_users/i)
  end
end

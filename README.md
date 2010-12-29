# ActiveColumn

ActiveColumn is a framework for working with data in Cassandra.  It currently includes two features:

- Database migrations
- "Time line" model data management

Data migrations are very similar to those in ActiveRecord, and are documented in [Migration](./docs/Migration.md).

Time line data management is loosely based on concepts in ActiveRecord, but is adapted to saving data in which rows in
Cassandra grow indefinitely over time, such as in the oft-used Twitter example for Cassandra.  This usage is documented
in:

- [CRUD](./docs/CRUD.md) - basic get, save, update, delete
- [Query](./docs/Query.md) - how to find data

## Installation

Add ActiveColumn to your Gemfile:
<pre>
gem 'active_column'
</pre>

Install with bundler:
<pre>
bundle install
</pre>

## Usage

### Configuration

ActiveColumn requires Cassandra 0.7 or above, as we as the [cassandra gem](https://github.com/fauna/cassandra),
version 0.9 or above.

Data migrations in ActiveColumn are used within a Rails project, and are driven off of a configuration file,
config/cassandra.yml.  It should look something like this:

_config/cassandra.yml_
<pre>
test:
  servers: "127.0.0.1:9160"
  keyspace: "myapp_test"
  thrift:
    timeout: 3
    retries: 2

development:
  servers: "127.0.0.1:9160"
  keyspace: "myapp_development"
  thrift:
    timeout: 3
    retries: 2
</pre>

In order to get time line modeling support, you must provide ActiveColumn with an instance of a Cassandra object.
Since you have your cassandra.yml from above, you can do this very simply like this:


_config/initializers/cassandra.rb_
<pre>
config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))[Rails.env]
$cassandra = Cassandra.new(config['keyspace'],
                           config['servers'],
                           config['thrift'])

ActiveColumn.connection = $cassandra
</pre>

As you can see, I create a global $cassandra variable, which I use in my tests to validate data directly in Cassandra.

One other thing to note is that you obviously must have Cassandra installed and running!  Please take a look at the
[mama_cass gem](https://github.com/carbonfive/mama_cass) for a quick way to get up and running with Cassandra for
development and testing.
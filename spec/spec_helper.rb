require 'cassandra/0.7'
require 'active_column'

Dir[ File.expand_path("../support/**/*.rb", __FILE__) ].each {|f| require f}

$cassandra = ActiveColumn.connection = Cassandra.new('system', '127.0.0.1:9160')

RSpec.configure do |config|

  config.before do
    Cleaner.drop
    Cleaner.create
    $cassandra.keyspace = 'active_column'
  end

end

class Cleaner
  def self.create
    # unless $cassandra.keyspaces.include? 'active_column'
      ks = Cassandra::Keyspace.new
      ks.name = 'active_column'
      ks.strategy_class = 'org.apache.cassandra.locator.LocalStrategy'
      ks.replication_factor = 1
      ks.cf_defs = []
      $cassandra.add_keyspace ks
    # end
  end

  def self.clean
    $cassandra.clear_keyspace!
    schema = $cassandra.schema
    schema.cf_defs.each do |cf_def|
      $cassandra.drop_column_family cf_def.name
    end
  end

  def self.drop
    $cassandra.drop_keyspace 'active_column'
  end
end

class Counter
  def initialize(cf, *keys)
    @cf = cf
    @keys = keys
    @counts = get_counts
  end

  def diff()
    new_counts = get_counts
    @keys.each_with_object( [] ) do |key, counts|
      counts << new_counts[key] - @counts[key]
    end
  end

  private

  def get_counts
    @keys.each_with_object( {} ) do |key, counts|
      p "CF: #{@cf}, Key: #{key}"
      counts[key] = $cassandra.count_columns(@cf, key, {})
    end
  end
end

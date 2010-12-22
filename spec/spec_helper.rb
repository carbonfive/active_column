require 'active_column'
require 'rails'
require 'rspec-rails'
require 'rspec/rails/adapters'
require 'wrong/adapters/rspec'

Wrong.config.alias_assert :expect

Dir[ File.expand_path("../support/**/*.rb", __FILE__) ].each {|f| require f}

$cassandra = ActiveColumn.connection = Cassandra.new('active_column', '127.0.0.1:9160')

ks_tasks = ActiveColumn::Tasks::Keyspace.new
unless ks_tasks.exists?('active_column')
  ks_tasks.create('active_column')

  cf_tasks = ActiveColumn::Tasks::ColumnFamily.new
  [:tweets, :tweet_dms].each do |cf|
    cf_tasks.create(cf, :keyspace => 'active_column')
  end
end

ks_tasks.set 'active_column'
ks_tasks.clear

RSpec.configure do |config|

  config.before do
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
      counts[key] = $cassandra.get(@cf, key).length
    end
  end
end

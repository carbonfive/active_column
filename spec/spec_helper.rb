require 'cassandra'
require 'active_column'

Dir[ File.expand_path("../support/**/*.rb", __FILE__) ].each {|f| require f}

$cassandra = ActiveColumn.connection = Cassandra.new('active_column', '127.0.0.1:9160')
$cassandra.clear_keyspace!

RSpec.configure do |config|

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
      counts[key] = $cassandra.count_columns(@cf, key)
    end
  end
end
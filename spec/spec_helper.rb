require 'cassandra'
require 'active_column'

Dir[ File.expand_path("../support/**/*.rb", __FILE__) ].each {|f| require f}

$cassandra = ActiveColumn.connection = Cassandra.new('active_column', '127.0.0.1:9160')
$cassandra.clear_keyspace!

RSpec.configure do |config|

end
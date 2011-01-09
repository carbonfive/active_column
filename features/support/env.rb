require 'cassandra/0.7'
$cassandra = Cassandra.new 'system'
begin
  $cassandra.keyspaces
rescue CassandraThrift::Cassandra::Client::TransportException => ex
  puts '!!!CASSANDRA MUST BE RUNNING ON http://localhost:9160!!!'
  Cucumber.wants_to_quit = true
end

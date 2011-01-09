Before do 
  @aruba_timeout_seconds = 10
end

Before do
  non_system_keyspaces = $cassandra.keyspaces - ['system']
  non_system_keyspaces.each do |non_system_keyspace|
    $cassandra.drop_keyspace non_system_keyspace
  end
end

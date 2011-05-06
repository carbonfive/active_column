module ActiveColumn

  module Configuration

    def connect(config)
      thrift = { :timeout => 3, :retries => 2, :server_retry_period => nil }
      self.connection = Cassandra.new(config['keyspace'], config['servers'], thrift)
    end

    def connected?
      defined? @@connection
    end

    def connection
      @@connection
    end

    def connection=(connection)
      @@connection = connection
      @@keyspace_tasks = ActiveColumn::Tasks::Keyspace.new
      @@keyspace = connection.keyspace
    end

    def keyspace_tasks
      @@keyspace_tasks
    end

    def column_family_tasks
      ActiveColumn::Tasks::ColumnFamily.new(@@keyspace)
    end

  end

end

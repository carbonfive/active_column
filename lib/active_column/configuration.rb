module ActiveColumn

  module Configuration

    def connect(config)
      default_thrift_options = { :timeout => 3, :retries => 2, :server_retry_period => nil }
      override_thrift_options = (config['thrift'] || {}).inject({}){|h, (k, v)| h[k.to_sym] = v; h} # symbolize keys
      thrift_options = default_thrift_options.merge(override_thrift_options)
      self.connection = Cassandra.new(config['keyspace'], config['servers'], thrift_options)
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

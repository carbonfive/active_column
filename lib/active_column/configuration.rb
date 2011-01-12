module ActiveColumn

  module Configuration

    def connection
      @@connection
    end

    def connection=(connection)
      @@connection = connection
      @@keyspace_tasks = ActiveColumn::Tasks::Keyspace.new
    end

    def keyspace_tasks
      @@keyspace_tasks
    end

    def column_family_tasks(keyspace = nil)
      ActiveColumn::Tasks::ColumnFamily.new(keyspace || @@keyspace_tasks.get)
    end

  end

end

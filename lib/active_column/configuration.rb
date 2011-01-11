module ActiveColumn

  module Configuration

    def connection
      @@connection
    end

    def connection=(connection)
      @@connection = connection
      @@keyspace_tasks = ActiveColumn::Tasks::Keyspace.new
      @@column_family_tasks = ActiveColumn::Tasks::ColumnFamily.new
    end

    def keyspace_tasks
      @@keyspace_tasks
    end

    def column_family_tasks
      @@column_family_tasks
    end

  end

end

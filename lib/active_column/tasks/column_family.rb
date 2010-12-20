module ActiveColumn

  module Tasks

    class ColumnFamily

      def initialize
        @cassandra = ActiveColumn.connection
      end

      def exists?(name)
        @cassandra.schema.cf_defs.find { |cf_def| cf_def.name == name.to_s }
      end

      def create(name, options = {})
        cf = Cassandra::ColumnFamily.new
        cf.name = name.to_s
        cf.keyspace = options[:keyspace] || @cassandra.keyspace
        cf.comparator_type = options[:comparator_type] || 'TimeUUIDType'
        @cassandra.add_column_family(cf)
      end

      def drop(name)
        @cassandra.drop_column_family(name.to_s)
      end

      def clear(name)
        @cassandra.truncate!(name.to_s)
      end

    end

  end

end



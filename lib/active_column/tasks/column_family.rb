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
        opts = { :name => name.to_s,
                 :keyspace => @cassandra.keyspace,
                 :comparator_type => 'TimeUUIDType' }.merge(options)

        cf = Cassandra::ColumnFamily.new.with_fields(opts)
        @cassandra.add_column_family(cf)
      end

      def drop(name)
        @cassandra.drop_column_family(name.to_s)
      end

      def clear(name)
        @cassandra.truncate!(name.to_s)
      end

    end

    private

    COMPARATOR_TYPES = { :time => 'TimeUUIDType',
                         :timestamp => 'TimeUUIDType',
                         :long => 'LongType',
                         :string => 'BytesType' }

    def post_process_options(options)

    end

  end

end

class Cassandra
  class ColumnFamily
    def with_fields(options)
      struct_fields.collect { |f| f[1][:name] }.each do |f|
        send("#{f}=", options[f.to_sym])
      end
      self
    end
  end
end



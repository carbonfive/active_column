module ActiveColumn

  module Tasks

    class ColumnFamily

      COMPARATOR_TYPES = { :time      => 'TimeUUIDType',
                           :timestamp => 'TimeUUIDType',
                           :long      => 'LongType',
                           :string    => 'BytesType' }

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

      private

      def post_process_options(options)
        type = options[:comparator_type]
        if type && COMPARATOR_TYPES.has_key?(type)
          options[:comparator_type] = COMPARATOR_TYPES[type]
        end
        options
      end

    end

  end

end

class Cassandra
  class ColumnFamily
    def with_fields(options)
      struct_fields.collect { |f| f[1][:name] }.each do |f|
        send("#{f}=", options[f.to_sym] || options[f.to_s])
      end
      self
    end
  end
end



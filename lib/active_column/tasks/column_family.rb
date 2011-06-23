module ActiveColumn

  module Tasks

    class ColumnFamily

      COMPARATOR_TYPES = { :time      => 'TimeUUIDType',
                           :timestamp => 'TimeUUIDType',
                           :long      => 'LongType',
                           :string    => 'BytesType',
                           :utf8      => 'UTF8Type',
                           :lexical_uuid => 'LexicalUUIDType'}
                           
      COLUMN_TYPES = {:super => 'Super',
                      :standard => 'Standard'}

      def initialize(keyspace)
        raise 'Cannot operate on system keyspace' if keyspace == 'system'
        @keyspace = keyspace
      end

      def exists?(name)
        connection.schema.cf_defs.find { |cf_def| cf_def.name == name.to_s }
      end

      def create(name, &block)
        cf = Cassandra::ColumnFamily.new
        cf.name = name.to_s
        cf.keyspace = @keyspace.to_s
        cf.comparator_type = 'TimeUUIDType'

        block.call cf if block

        post_process_column_family(cf)
        if exists?(cf.name)
          puts "#{cf.name} already exists in this keyspace, so we cannot add it."
        else
          connection.add_column_family(cf)
        end
      end

      def drop(name)
        if not exists?(name)
          puts "#{name} does not exist in this keyspace, so we cannot drop it."
        else
          connection.drop_column_family(name.to_s)
        end
      end

      def rename(old_name, new_name)
        connection.rename_column_family(old_name.to_s, new_name.to_s)
      end

      def clear(name)
        connection.truncate!(name.to_s)
      end

      private

      def connection
        ActiveColumn.connection
      end

      def post_process_column_family(cf)
        type = cf.comparator_type
        if type && COMPARATOR_TYPES.has_key?(type)
          cf.comparator_type = COMPARATOR_TYPES[type]
        end
        cf
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


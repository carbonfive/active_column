module ActiveColumn

  module Tasks

    class ColumnFamily

      COMPARATOR_TYPES = { :time         => 'TimeUUIDType',
                           :timestamp    => 'TimeUUIDType',
                           :long         => 'LongType',
                           :string       => 'BytesType',
                           :utf8         => 'UTF8Type',
                           :lexical_uuid => 'LexicalUUIDType'}
                           
      COLUMN_TYPES = { :super    => 'Super',
                       :standard => 'Standard' }

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
        connection.add_column_family(cf)
      end

      def update(name, &block)
        cfs = connection.schema.cf_defs.select do |column_family|
          column_family.name == name.to_s
        end

        cf = cfs.first # only the first matching cf of that name
        raise "Can not find column family #{name}" if cf.nil?
        
        block.call cf if block
        
        post_process_column_family(cf)
        connection.update_column_family(cf)
      end

      def drop(name)
        connection.drop_column_family(name.to_s)
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
        
        subtype = cf.subcomparator_type
        if subtype && COMPARATOR_TYPES.has_key?(subtype)
          cf.subcomparator_type = COMPARATOR_TYPES[subtype]
        end
        
        column_type = cf.column_type.to_s.downcase.to_sym
        if COLUMN_TYPES.has_key?(column_type)
          cf.column_type = COLUMN_TYPES[column_type]
        else
          raise ArgumentError, "Unrecognized column_type #{column_type}"
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


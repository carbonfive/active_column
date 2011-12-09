module ActiveColumn

  module Tasks

    class ColumnFamily

      include ActiveColumn::Constants
      
      def initialize(keyspace)
        raise 'Cannot operate on system keyspace' if keyspace == 'system'
        @keyspace = keyspace
      end

      def exists?(name)
        ! find_by_name(name).nil?
      end

      def create(name, &block)
        cf = ActiveColumn::Types::ColumnFamily.new
        cf.name = name.to_s
        cf.keyspace = @keyspace.to_s
        cf.comparator_type = 'TimeUUIDType'
	cf.column_metadata = []

        block.call cf if block

        post_process_column_family(cf)
        connection.add_column_family(cf)
      end

      def update(name, &block)
        cf = find_by_name(name)
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

      def find_by_name(name)
        connection.schema.cf_defs.find { |cf_def| cf_def.name == name.to_s }
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
  
	replace = ["comparator_type", "default_validation_class", "key_validation_class"]
	replace.each do |rep|
	  attr = cf.send(rep)
	  next unless attr.is_a? Symbol
	  if COMPARATOR_TYPES.has_key?(attr)
	    cf.send("#{rep}=", COMPARATOR_TYPES[attr])
	  else
	    raise ArgumentError, "Unrecognized #{rep}: #{attr}"
	  end
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


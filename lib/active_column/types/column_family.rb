module ActiveColumn
  module Types
    class ColumnFamily < Cassandra::ColumnFamily

      include ActiveColumn::Constants

      def column(name, &block)	
	cd = CassandraThrift::ColumnDef.new
	cd.name = name.to_s
	block.call cd if block	
	post_process_column_metadata(cd)
	self.column_metadata << cd
      end	

      private

      def post_process_column_metadata(cd)
	validation_class = cd.validation_class
	if validation_class && COMPARATOR_TYPES.has_key?(validation_class)
	  cd.validation_class = COMPARATOR_TYPES[validation_class]
	end	  
      end
    end 
  end
end

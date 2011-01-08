module ActiveColumn

  module Tasks

    class Keyspace

      def self.parse(hash)
        ks = Cassandra::Keyspace.new.with_fields hash
        ks.cf_defs = []
        hash['cf_defs'].each do |cf|
          ks.cf_defs << Cassandra::ColumnFamily.new.with_fields(cf)
        end
        ks
      end

      def initialize
        c = ActiveColumn.connection
        @cassandra = Cassandra.new('system', c.servers, c.thrift_client_options)
      end

      def exists?(name)
        @cassandra.keyspaces.include? name.to_s
      end

      def create(name, options = {})
        opts = { :name => name.to_s,
                 :strategy_class => 'org.apache.cassandra.locator.LocalStrategy',
                 :replication_factor => 1,
                 :cf_defs => [] }.merge(options)

        ks = Cassandra::Keyspace.new.with_fields(opts)
        @cassandra.add_keyspace ks
      end

      def drop(name)
        @cassandra.drop_keyspace name.to_s
      end

      def set(name)
        @cassandra.keyspace = name.to_s
      end

      def get
        @cassandra.keyspace
      end

      def clear
        return puts 'Cannot clear system keyspace' if @cassandra.keyspace == 'system'

        @cassandra.clear_keyspace!
      end

      def schema_dump
        @cassandra.schema
      end

      def schema_load(schema)
        @cassandra.schema.cf_defs.each do |cf|
          @cassandra.drop_column_family cf.name
        end

        keyspace = get
        schema.cf_defs.each do |cf|
          cf.keyspace = keyspace
          @cassandra.add_column_family cf
        end
      end

    end

  end

end

class Cassandra
  class Keyspace
    def with_fields(options)
      struct_fields.collect { |f| f[1][:name] }.each do |f|
        send("#{f}=", options[f.to_sym] || options[f.to_s])
      end
      self
    end
  end
end

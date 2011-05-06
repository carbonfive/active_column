module ActiveColumn

  module Tasks

    class Keyspace
      include ActiveColumn::Helpers

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
        if exists? name
          log "Keyspace '#{name}' already exists - cannot create"
          return nil
        end

        opts = { :name => name.to_s,
                 :strategy_class => 'org.apache.cassandra.locator.LocalStrategy',
                 :replication_factor => 1,
                 :cf_defs => [] }.merge(options)

        ks = Cassandra::Keyspace.new.with_fields(opts)
        @cassandra.add_keyspace ks
        ks
      end

      def drop(name)
        return log 'Cannot drop system keyspace' if name == 'system'
        return log "Keyspace '#{name}' does not exist - cannot drop" if !exists? name
        @cassandra.drop_keyspace name.to_s
        true
      end

      def set(name)
        return log "Keyspace '#{name}' does not exist - cannot set" if !exists? name
        @cassandra.keyspace = name.to_s
      end

      def get
        @cassandra.keyspace
      end

      def clear
        return log 'Cannot clear system keyspace' if @cassandra.keyspace == 'system'
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

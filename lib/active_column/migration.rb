module ActiveColumn

  class Migration

    @@verbose = true
    cattr_accessor :verbose

    def self.connection
      $cassandra
    end

    def self.migrate(direction)
      return unless respond_to?(direction)

      case direction
        when :up   then announce "migrating"
        when :down then announce "reverting"
      end

      result = nil
      time = Benchmark.measure { result = send("#{direction}") }

      case direction
        when :up   then announce "migrated (%.4fs)" % time.real; write
        when :down then announce "reverted (%.4fs)" % time.real; write
      end

      result
    end

    def self.create_column_family(name, options = {})
      if block_given?
        cf_opts = ColumnFamilyOptions.new
        yield cf_opts
        options.merge! cf_opts.options
      end

      ActiveColumn::Tasks::ColumnFamily.create(name, options)
    end

    def self.drop_column_family(name)
      ActiveColumn::Tasks::ColumnFamily.drop(name)
    end

    def self.write(text="")
      puts(text) if verbose
    end

    def self.announce(message)
      version = defined?(@version) ? @version : nil

      text = "#{version} #{name}: #{message}"
      length = [0, 75 - text.length].max
      write "== %s %s" % [text, "=" * length]
    end

    def self.say(message, subitem=false)
      write "#{subitem ? "   ->" : "--"} #{message}"
    end

    def self.say_with_time(message)
      say(message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end

    def self.suppress_messages
      save, self.verbose = verbose, false
      yield
    ensure
      self.verbose = save
    end

  end

  # MigrationProxy is used to defer loading of the actual migration classes
  # until they are needed
  class MigrationProxy

    attr_accessor :name, :version, :filename

    delegate :migrate, :announce, :write, :to=>:migration

    private

    def migration
      @migration ||= load_migration
    end

    def load_migration
      require(File.expand_path(filename))
      name.constantize
    end

  end

  private

  class ColumnFamilyOptions
    Cassandra::ColumnFamily::FIELDS.values.each do |f|
      name = f[:name]
      define_method("#{name}=") do|val|
        @options[name.to_sym] = val
      end
    end

    attr_reader :options

    def initialize
      @options = {}
    end
  end

end

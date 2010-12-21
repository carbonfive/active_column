module ActiveColumn

  class IrreversibleMigration < ActiveColumnError
  end

  class DuplicateMigrationVersionError < ActiveColumnError#:nodoc:
    def initialize(version)
      super("Multiple migrations have the version number #{version}")
    end
  end

  class DuplicateMigrationNameError < ActiveColumnError#:nodoc:
    def initialize(name)
      super("Multiple migrations have the name #{name}")
    end
  end

  class UnknownMigrationVersionError < ActiveColumnError #:nodoc:
    def initialize(version)
      super("No migration with version number #{version}")
    end
  end

  class IllegalMigrationNameError < ActiveColumnError#:nodoc:
    def initialize(name)
      super("Illegal name for migration file: #{name}\n\t(only lower case letters, numbers, and '_' allowed)")
    end
  end

  class Migration

    def self.connection
      $cassandra
    end

    def self.migrate(direction)
      return unless respond_to?(direction)
      send direction
    end

    def self.create_column_family(name, options = {})
      ActiveColumn::Tasks::ColumnFamily.new.create(name, options)
    end

    def self.drop_column_family(name)
      ActiveColumn::Tasks::ColumnFamily.new.drop(name)
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

  class Migrator

    def self.migrate(migrations_path, target_version = nil)
      case
        when target_version.nil?
          up(migrations_path, target_version)
        when current_version == 0 && target_version == 0
        when current_version > target_version
          down(migrations_path, target_version)
        else
          up(migrations_path, target_version)
      end
    end

    def self.rollback(migrations_path, steps = 1)
      move(:down, migrations_path, steps)
    end

    def self.forward(migrations_path, steps = 1)
      move(:up, migrations_path, steps)
    end

    def self.up(migrations_path, target_version = nil)
      self.new(:up, migrations_path, target_version).migrate
    end

    def self.down(migrations_path, target_version = nil)
      self.new(:down, migrations_path, target_version).migrate
    end

    def self.run(direction, migrations_path, target_version)
      self.new(direction, migrations_path, target_version).run
    end

    def self.migrations_path
      'ks/migrate'
    end

    def self.schema_migrations_column_family
      :schema_migrations
    end

    def self.get_all_versions
      cas = ActiveColumn.connection
      cas.get(schema_migrations_column_family, 'all').map {|(name, _value)| name.to_i}.sort
    end

    def self.current_version
      sm_cf = schema_migrations_column_family
      cf = ActiveColumn::Tasks::ColumnFamily.new
      if cf.exists?(sm_cf)
        get_all_versions.max || 0
      else
        0
      end
    end

    private

    def self.move(direction, migrations_path, steps)
      migrator = self.new(direction, migrations_path)
      start_index = migrator.migrations.index(migrator.current_migration)

      if start_index
        finish = migrator.migrations[start_index + steps]
        version = finish ? finish.version : 0
        send(direction, migrations_path, version)
      end
    end

    public

    def initialize(direction, migrations_path, target_version = nil)
      cf = ActiveColumn::Tasks::ColumnFamily.new
      sm_cf = self.class.schema_migrations_column_family

      unless cf.exists?(sm_cf)
        cf.create(sm_cf, :comparator_type => 'LongType')
      end

      @direction, @migrations_path, @target_version = direction, migrations_path, target_version
    end

    def current_version
      migrated.last || 0
    end

    def current_migration
      migrations.detect { |m| m.version == current_version }
    end

    def run
      target = migrations.detect { |m| m.version == @target_version }
      raise UnknownMigrationVersionError.new(@target_version) if target.nil?
      unless (up? && migrated.include?(target.version.to_i)) || (down? && !migrated.include?(target.version.to_i))
        target.migrate(@direction)
        record_version_state_after_migrating(target)
      end
    end

    def migrate
      current = migrations.detect { |m| m.version == current_version }
      target = migrations.detect { |m| m.version == @target_version }

      if target.nil? && !@target_version.nil? && @target_version > 0
        raise UnknownMigrationVersionError.new(@target_version)
      end

      start = up? ? 0 : (migrations.index(current) || 0)
      finish = migrations.index(target) || migrations.size - 1
      runnable = migrations[start..finish]

      # skip the last migration if we're headed down, but not ALL the way down
      runnable.pop if down? && !target.nil?

      runnable.each do |migration|
        #puts "Migrating to #{migration.name} (#{migration.version})"

        # On our way up, we skip migrating the ones we've already migrated
        next if up? && migrated.include?(migration.version.to_i)

        # On our way down, we skip reverting the ones we've never migrated
        if down? && !migrated.include?(migration.version.to_i)
          migration.announce 'never migrated, skipping'; migration.write
          next
        end

        migration.migrate(@direction)
        record_version_state_after_migrating(migration)
      end
    end

    def migrations
      @migrations ||= begin
        files = Dir["#{@migrations_path}/[0-9]*_*.rb"]

        migrations = files.inject([]) do |klasses, file|
          version, name = file.scan(/([0-9]+)_([_a-z0-9]*).rb/).first

          raise IllegalMigrationNameError.new(file) unless version
          version = version.to_i

          if klasses.detect { |m| m.version == version }
            raise DuplicateMigrationVersionError.new(version)
          end

          if klasses.detect { |m| m.name == name.camelize }
            raise DuplicateMigrationNameError.new(name.camelize)
          end

          migration = MigrationProxy.new
          migration.name     = name.camelize
          migration.version  = version
          migration.filename = file
          klasses << migration
        end

        migrations = migrations.sort_by { |m| m.version }
        down? ? migrations.reverse : migrations
      end
    end

    def pending_migrations
      already_migrated = migrated
      migrations.reject { |m| already_migrated.include?(m.version.to_i) }
    end

    def migrated
      @migrated_versions ||= self.class.get_all_versions
    end

    private

    def record_version_state_after_migrating(migration)
      cas = ActiveColumn.connection
      sm_cf = self.class.schema_migrations_column_family

      @migrated_versions ||= []
      if down?
        @migrated_versions.delete(migration.version)
        cas.remove sm_cf, 'all', migration.version
      else
        @migrated_versions.push(migration.version).sort!
        cas.insert sm_cf, 'all', { migration.version => migration.name }
      end
    end

    def up?
      @direction == :up
    end

    def down?
      @direction == :down
    end

  end

end

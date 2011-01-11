require 'rake'
require 'active_column/tasks/keyspace'
require 'active_column/tasks/column_family'

namespace :ks do

  task :configure => :environment do
    @configs = YAML.load_file(Rails.root.join("config", "cassandra.yml"))
    @config = @configs[Rails.env || 'development']
  end

  task :set_keyspace => :configure do
    set_keyspace
  end

  desc 'Create the keyspace in config/cassandra.yml for the current environment'
  task :create => :configure do
    ActiveColumn::Tasks::Keyspace.new.create @config['keyspace'], @config
    puts "Created keyspace: #{@config['keyspace']}"
  end

  namespace :create do
    desc 'Create keyspaces in config/cassandra.yml for all environments'
    task :all => :configure do
      created = []
      @configs.values.each do |config|
        ActiveColumn::Tasks::Keyspace.new.create config['keyspace'], config
        created << config['keyspace']
      end
      puts "Created keyspaces: #{created.join(', ')}"
    end
  end

  desc 'Drop keyspace in config/cassandra.yml for the current environment'
  task :drop => :configure do
    ActiveColumn::Tasks::Keyspace.new.drop @config['keyspace']
    puts "Dropped keyspace: #{@config['keyspace']}"
  end

  namespace :drop do
    desc 'Drop keyspaces in config/cassandra.yml for all environments'
    task :all => :configure do
      dropped = []
      @configs.values.each do |config|
        ActiveColumn::Tasks::Keyspace.new.drop config['keyspace']
        dropped << config['keyspace']
      end
      puts "Dropped keyspaces: #{dropped.join(', ')}"
    end
  end

  desc 'Migrate the keyspace (options: VERSION=x)'
  task :migrate => :set_keyspace do
    version = ( ENV['VERSION'] ? ENV['VERSION'].to_i : nil )
    ActiveColumn::Migrator.migrate ActiveColumn::Migrator.migrations_path, version
    schema_dump
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n)'
  task :rollback => :set_keyspace do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveColumn::Migrator.rollback ActiveColumn::Migrator.migrations_path, step
    schema_dump
  end

  desc 'Pushes the schema to the next version (specify steps w/ STEP=n)'
  task :forward => :set_keyspace do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveColumn::Migrator.forward ActiveColumn::Migrator.migrations_path, step
    schema_dump
  end

  namespace :schema do
    desc 'Create ks/schema.json file that can be portably used against any Cassandra instance supported by ActiveColumn'
    task :dump => :configure do
      schema_dump
    end

    desc 'Load ks/schema.json file into Cassandra'
    task :load => :configure do
      schema_load
    end
  end

  namespace :test do
    desc 'Load the development schema in to the test keyspace'
    task :prepare => :configure do
      schema_dump :development
      schema_load :test
    end
  end

  desc 'Retrieves the current schema version number'
  task :version => :set_keyspace do
    version = ActiveColumn::Migrator.current_version
    puts "Current version: #{version}"
  end

  private

  def schema_dump(env = Rails.env)
    ks = set_keyspace env
    File.open "#{Rails.root}/ks/schema.json", 'w' do |file|
      file.puts ks.schema_dump.to_json
    end
  end

  def schema_load(env = Rails.env)
    ks = set_keyspace env
    File.open "#{Rails.root}/ks/schema.json", 'r' do |file|
      hash = JSON.parse(file.read(nil))
      ks.schema_load ActiveColumn::Tasks::Keyspace.parse(hash)
    end
  end

  def set_keyspace(env = Rails.env)
    config = @configs[env.to_s || 'development']
    ks = ActiveColumn::Tasks::Keyspace.new
    ks.set config['keyspace']
    ks
  end

end


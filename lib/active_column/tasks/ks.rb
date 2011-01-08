require 'rake'
require 'active_column/tasks/keyspace'
require 'active_column/tasks/column_family'

namespace :ks do

  desc 'Create the keyspace in config/cassandra.yml for the current environment'
  task :create => :environment do
    config = load_config[Rails.env || 'development']
    ks = config['keyspace']
    ActiveColumn::Tasks::Keyspace.new.create ks, config
    puts "Created keyspace: #{ks}"
  end

  desc 'Create keyspaces in config/cassandra.yml for all environments'
  task 'create:all' => :environment do
    config = load_config
    kss = []
    config.keys.each do |env|
      kss << config[env]['keyspace']
      ActiveColumn::Tasks::Keyspace.new.create kss.last, config
    end
    puts "Created keyspaces: #{kss.join(', ')}"
  end

  desc 'Drop keyspace in config/cassandra.yml for the current environment'
  task :drop => :environment do
    config = load_config[Rails.env || 'development']
    ks = config['keyspace']
    ActiveColumn::Tasks::Keyspace.new.drop ks
    puts "Dropped keyspace: #{ks}"
  end

  desc 'Drop keyspaces in config/cassandra.yml for all environments'
  task 'drop:all' => :environment do
    config = load_config
    kss = []
    config.keys.each do |env|
      kss << config[env]['keyspace']
      ActiveColumn::Tasks::Keyspace.new.drop kss.last
    end
    puts "Dropped keyspaces: #{kss.join(', ')}"
  end

  desc 'Migrate the keyspace (options: VERSION=x)'
  task :migrate => :environment do
    set_keyspace
    version = ( ENV['VERSION'] ? ENV['VERSION'].to_i : nil )
    ActiveColumn::Migrator.migrate ActiveColumn::Migrator.migrations_path, version
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n)'
  task :rollback => :environment do
    set_keyspace
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveColumn::Migrator.rollback ActiveColumn::Migrator.migrations_path, step
  end

  desc 'Pushes the schema to the next version (specify steps w/ STEP=n)'
  task :forward => :environment do
    set_keyspace
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveColumn::Migrator.forward ActiveColumn::Migrator.migrations_path, step
  end

  namespace :schema do
    desc 'Create ks/schema.json file that can be portably used against any Cassandra instance supported by ActiveColumn'
    task :dump => :environment do
      schema_dump
    end

    desc 'Load ks/schema.json file into Cassandra'
    task :load => :environment do
      schema_load
    end
  end

  namespace :test do
    desc 'Load the development schema in to the test keyspace'
    task :prepare => :environment do
      schema_dump :development
      schema_load :test
    end
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

  def load_config
    YAML.load_file(Rails.root.join("config", "cassandra.yml"))
  end

  def set_keyspace(env = Rails.env)
    config = load_config[env.to_s || 'development']
    ks = ActiveColumn::Tasks::Keyspace.new
    ks.set config['keyspace']
    ks
  end

end


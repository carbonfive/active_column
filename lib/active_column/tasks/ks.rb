require 'rake'

namespace :ks do

  desc 'Create the keyspace in config/cassandra.yml for the current environment'
  task :create => :environment do
    config = load_config[Rails.env || 'development']
    ActiveColumn::Tasks::Keyspace.new.create config['keyspace'], config
  end

  desc 'Create keyspaces in config/cassandra.yml for all environments'
  task 'create:all' => :environment do
    config = load_config
    config.keys.each do |env|
      ActiveColumn::Tasks::Keyspace.new.create config[env]['keyspace'], config
    end
  end

  desc 'Drop keyspace in config/cassandra.yml for the current environment'
  task :drop => :environment do
    config = load_config[Rails.env || 'development']
    ActiveColumn::Tasks::Keyspace.new.drop config['keyspace']
  end

  desc 'Drop keyspaces in config/cassandra.yml for all environments'
  task 'drop:all' => :environment do
    config = load_config
    config.keys.each do |env|
      ActiveColumn::Tasks::Keyspace.new.drop config[env]['keyspace'], config
    end
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

  private

  def load_config
    YAML.load_file(Rails.root.join("config", "cassandra.yml"))
  end

  def set_keyspace
    config = load_config[Rails.env || 'development']
    ActiveColumn::Tasks::Keyspace.new.set config['keyspace']
  end

end


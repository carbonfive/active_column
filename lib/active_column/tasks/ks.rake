require 'rake'
require 'active_column/tasks/keyspace'
require 'active_column/tasks/column_family'

namespace :ks do

  if defined? ::Rails
    task :configure => :environment do
      configure
    end
  else
    task :configure do
      configure
    end
  end

  task :set_keyspace => :configure do
    set_keyspace
  end

  desc 'Create the keyspace in config/cassandra.yml for the current environment'
  task :create => :configure do
    ks = ActiveColumn::Tasks::Keyspace.new.create @config['keyspace'], @config
    puts "Created keyspace: #{@config['keyspace']}" if ks
  end

  namespace :create do
    desc 'Create keyspaces in config/cassandra.yml for all environments'
    task :all => :configure do
      @configs.values.each do |config|
        ks = ActiveColumn::Tasks::Keyspace.new.create config['keyspace'], config
        puts "Created keyspace: #{config['keyspace']}" if ks
      end
    end
  end

  desc 'Drop keyspace in config/cassandra.yml for the current environment'
  task :drop => :configure do
    dropped = ActiveColumn::Tasks::Keyspace.new.drop @config['keyspace']
    puts "Dropped keyspace: #{@config['keyspace']}" if dropped
  end

  namespace :drop do
    desc 'Drop keyspaces in config/cassandra.yml for all environments'
    task :all => :configure do
      @configs.values.each do |config|
        dropped = ActiveColumn::Tasks::Keyspace.new.drop config['keyspace']
        puts "Dropped keyspace: #{config['keyspace']}" if dropped
      end
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

  def current_root
    return Rails.root.to_s if defined? ::Rails
    '.'
  end

  def configure
    file = "#{current_root}/config/cassandra.yml"
    @configs = YAML::load(ERB.new(IO.read(file)).result)
    @config = @configs[ActiveColumn::Helpers.current_env]
    ActiveColumn.connect @config
  end

  def schema_dump(env = ActiveColumn::Helpers.current_env)
    ks = set_keyspace env
    File.open "#{current_root}/ks/schema.json", 'w' do |file|
      basic_json = ks.schema_dump.to_json
      formatted_json = JSON.pretty_generate(JSON.parse(basic_json))
      file.puts formatted_json
    end
  end

  def schema_load(env = ActiveColumn::Helpers.current_env)
    ks = set_keyspace env
    File.open "#{current_root}/ks/schema.json", 'r' do |file|
      hash = JSON.parse(file.read(nil))
      ks.schema_load ActiveColumn::Tasks::Keyspace.parse(hash)
    end
  end

  def set_keyspace(env = ActiveColumn::Helpers.current_env)
    config = @configs[env.to_s || 'development']
    ks = ActiveColumn::Tasks::Keyspace.new
    keyspace = config['keyspace']
    unless ks.exists? keyspace
      puts "Keyspace '#{keyspace}' does not exist - Try 'rake ks:create'"
      exit 1
    end
    ks.set keyspace
    ks
  end

end
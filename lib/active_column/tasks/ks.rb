require 'rake'

namespace :ks do

  desc 'Create the keyspace in config/cassandra.yml for the current environment'
  task :create => :environment do
    config = load_config[Rails.env]
    ActiveColumn::Tasks::Keyspace.new.create config[:keyspace], config
  end

  desc 'Create keyspaces in config/cassandra.yml for all environments'
  task 'create:all' => :environment do
    config = load_config
    config.keys.each do |env|
      ActiveColumn::Tasks::Keyspace.new.create config[env][:keyspace], config
    end
  end

  desc 'Drop keyspace in config/cassandra.yml for the current environment'
  task :drop => :environment do
    config = load_config[Rails.env]
    ActiveColumn::Tasks::Keyspace.new.drop config[:keyspace]
  end

  desc 'Drop keyspaces in config/cassandra.yml for all environments'
  task 'deop:all' => :environment do
    config = load_config
    config.keys.each do |env|
      ActiveColumn::Tasks::Keyspace.new.drop config[env][:keyspace], config
    end
  end

end

def load_config
  YAML.load_file(Rails.root.join("config", "cassandra.yml"))
end
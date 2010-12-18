require 'rake'

namespace :ks do

  desc 'Create the keyspace in config/cassandra.yml for the current environment'
  task :create => :environment do
    config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))[Rails.env]
    ActiveColumn::Tasks::Keyspace.new.create config[:keyspace], config
  end

  desc 'Create keyspaces in config/cassandra.yml for development and test environments'
  task 'create:all' => :environment do
    config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))
    [:development, :test].each do |env|
      ActiveColumn::Tasks::Keyspace.new.create config[env][:keyspace], config
    end
  end

end
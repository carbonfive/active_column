require 'cassandra/0.8' unless defined? ::Cassandra
require 'benchmark'
require 'yaml'
require 'erb'

module ActiveColumn

  autoload :Base,           'active_column/base'
  autoload :Configuration,  'active_column/configuration'
  autoload :KeyConfig,      'active_column/key_config'
  autoload :Version,        'active_column/version'
  autoload :Helpers,        'active_column/helpers'

  require                   'active_column/errors'
  require                   'active_column/migrator'
  require                   'active_column/migration'

  module Tasks
    autoload :Keyspace,     'active_column/tasks/keyspace'
    autoload :ColumnFamily, 'active_column/tasks/column_family'
  end

  load                      'active_column/tasks/ks.rake'


  if defined? ::Rails
    module Generators
      if ::Rails::VERSION::MAJOR >= 3
        require             'active_column/generators/migration_generator'
      end
    end
  end

  extend Configuration

end

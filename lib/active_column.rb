require 'cassandra/0.7'
require 'benchmark'
require 'yaml'

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

  if defined? ::Rails
    module Generators
      require               'active_column/generators/migration_generator'
    end
  end

  extend Configuration

end

require 'cassandra/0.7'
require 'active_support/core_ext/string'

module ActiveColumn

  autoload :Base,           'active_column/base'
  autoload :Connection,     'active_column/connection'
  autoload :KeyConfig,      'active_column/key_config'
  autoload :Version,        'active_column/version'

  require                   'active_column/errors'
  require                   'active_column/migrator'

  module Tasks
    autoload :Keyspace,     'active_column/tasks/keyspace'
    autoload :ColumnFamily, 'active_column/tasks/column_family'

    require                 'active_column/tasks/ks'
  end

  extend Connection
  
end

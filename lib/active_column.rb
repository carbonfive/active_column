module ActiveColumn

  autoload :Connection,     'active_column/connection'
  autoload :Base,           'active_column/base'
  autoload :KeyConfig,      'active_column/key_config'
  autoload :Version,        'active_column/version'

  module Tasks
    autoload :Keyspace,     'active_column/tasks/keyspace'
    autoload :ColumnFamily, 'active_column/tasks/column_family'
  end


  extend Connection
  
end

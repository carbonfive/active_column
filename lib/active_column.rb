module ActiveColumn

  autoload :Connection, 'active_column/connection'
  autoload :Base,       'active_column/base'
  autoload :KeyConfig,  'active_column/key_config'
  autoload :Version,    'active_column/version'

  extend Connection
  
end

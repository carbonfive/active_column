module ActiveColumn

  autoload :Connection, 'active_column/connection'
  autoload :Base,       'active_column/base'
  autoload :Version,    'active_column/version'

  extend Connection
  
end

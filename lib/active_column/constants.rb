module ActiveColumn
  module Constants
    COMPARATOR_TYPES = { 
      :time         => 'TimeUUIDType',
      :timestamp    => 'TimeUUIDType',
      :long         => 'LongType',
      :string       => 'BytesType',
      :utf8         => 'UTF8Type',
      :lexical_uuid => 'LexicalUUIDType',
      :double	    => 'DoubleType'
    }

    COLUMN_TYPES = { 
      :super    => 'Super',
      :standard => 'Standard' 
    }
  end
end

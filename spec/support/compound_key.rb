class CompoundKey < ActiveColumn::Base
  column_family :time
  keys [:one, :two, :three]
end
class CompoundKey < ActiveColumn::Base
  column_family :time
  key :one
  key :two
  key :three
end
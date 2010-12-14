class SimpleKey < ActiveColumn::Base
  column_family :time
  key :one
end
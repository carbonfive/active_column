class SimpleKey < ActiveColumn::Base
  column_family :time
  keys :one
end
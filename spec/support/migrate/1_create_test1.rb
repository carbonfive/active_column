class CreateTest1 < ActiveColumn::Migration

  def self.up
    create_column_family :test1, :comparator_type => 'BytesType'
  end

  def self.down
    drop_column_family :test1
  end
  
end
class Migration1 < ActiveColumn::Migration

  def self.up
    $migrator_spec_data[1] = true
  end

  def self.down
    $migrator_spec_data.delete 1
  end
  
end
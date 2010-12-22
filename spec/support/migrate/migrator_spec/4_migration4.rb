class Migration4 < ActiveColumn::Migration

  def self.up
    $migrator_spec_data[4] = true
  end

  def self.down
    $migrator_spec_data.delete 4
  end
  
end
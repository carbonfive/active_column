class Migration1 < ActiveColumn::Migration

  def self.up
    $migrator_spec_helper.data[1] = true
  end

  def self.down
    $migrator_spec_helper.data.delete 1
  end
  
end
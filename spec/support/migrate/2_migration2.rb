class Migration2 < ActiveColumn::Migration

  def self.up
    $migrator_spec_helper.data[2] = true
  end

  def self.down
    $migrator_spec_helper.data.delete 2
  end
  
end
class Migration4 < ActiveColumn::Migration

  def self.up
    $migrator_spec_helper.data[4] = true
  end

  def self.down
    $migrator_spec_helper.data.delete 4
  end
  
end
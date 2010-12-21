class Migration3 < ActiveColumn::Migration

  def self.up
    $migrator_spec_helper.data[3] = true
  end

  def self.down
    $migrator_spec_helper.data.delete 3
  end
  
end
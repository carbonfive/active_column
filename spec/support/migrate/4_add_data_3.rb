class AddData3 < ActiveColumn::Migration

  def self.up
    connection.insert("test1", "3", { "foo" => "bar" })
  end

  def self.down
    connection.remove("test1", "3")
  end

end
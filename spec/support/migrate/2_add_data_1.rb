class AddData1 < ActiveColumn::Migration

  def self.up
    connection.insert("test1", "1", { "foo" => "bar" })
  end

  def self.down
    connection.remove("test1", "1")
  end

end
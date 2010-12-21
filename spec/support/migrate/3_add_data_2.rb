class AddData2 < ActiveColumn::Migration

  def self.up
    connection.insert("test1", "2", { "foo" => "bar" })
  end

  def self.down
    connection.remove("test1", "2")
  end

end
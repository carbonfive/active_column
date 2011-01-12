require 'spec_helper'
require 'mocha'

describe ActiveColumn::Migration do
  describe '.create_column_family' do

    context 'given a block' do
      before do
        ActiveColumn.connection.expects(:add_column_family).with() do |cf|
          cf.name == 'foo' && cf.comment = 'some comment'
        end
      end

      it 'sends the settings to cassandra' do
        ActiveColumn::Migration.create_column_family :foo do |cf|
          cf.comment = 'some comment'
        end
      end
    end

    context 'given no block' do
      before do
        ActiveColumn.connection.expects(:add_column_family).with() do |cf|
          cf.name == 'foo' && cf.comment.nil?
        end
      end

      it 'sends the default settings to cassandra' do
        ActiveColumn::Migration.create_column_family :foo
      end
    end

  end

  describe '.drop_column_family' do
    context 'given a column family' do
      before do
        ActiveColumn.connection.expects(:drop_column_family).with('foo')
      end

      it 'drops it' do
        ActiveColumn::Migration.drop_column_family :foo
      end
    end
  end

  describe '.rename_column_family' do
    context 'given a column family and a new name' do
      before do
        ActiveColumn.connection.expects(:rename_column_family).with('old_foo', 'new_foo')
      end

      it 'renames it' do
        ActiveColumn::Migration.rename_column_family :old_foo, :new_foo
      end
    end
  end
end
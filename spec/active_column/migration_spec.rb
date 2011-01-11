require 'spec_helper'
require 'mocha'

describe ActiveColumn::Migration do
  describe '.create_column_family' do
    context 'given an options hash' do
      before do
        ActiveColumn::Tasks::ColumnFamily.
                stubs(:create).with('foo1', :comment => '1')
      end

      it 'receives an options hash' do
        ActiveColumn::Migration.create_column_family 'foo1', :comment => '1'
      end
    end

    context 'given a block' do
      before do
        ActiveColumn::Tasks::ColumnFamily.
                stubs(:create).with('foo2', :comment => '1')
      end

      it 'receives the options has a hash' do
        ActiveColumn::Migration.create_column_family 'foo2' do |cf|
          cf.comment = '1'
        end
      end
    end

    context 'given an options hash and a block' do
      before do
        ActiveColumn::Tasks::ColumnFamily.
                stubs(:create).with('foo3', :comment => '2')
      end

      it 'receives the options has a hash with the block overriding the hash' do
        ActiveColumn::Migration.create_column_family('foo3', :comment => '1') do |cf|
          cf.comment = '2'
        end
      end
    end
  end
end
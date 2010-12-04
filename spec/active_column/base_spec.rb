require 'spec_helper'

describe ActiveColumn::Base do

  describe '#save' do
    before do
      @count1 = $cassandra.count_columns(:time, "1")
      @count2 = $cassandra.count_columns(:time, "2")
      SimpleKey.new.save(["1", "2"])
    end

    it 'saves the object for all keys' do
      $cassandra.count_columns(:time, "1").should == @count1 + 1
      $cassandra.count_columns(:time, "2").should == @count1 + 1
    end
  end

  describe '.find' do

    context 'given a simple key' do
      before do
        
      end
    end

    context 'given a compound key' do

    end

  end

  describe '.generate_keys' do

    context 'given a simple key model' do
      before do
        @model = SimpleKey.new
      end

      context 'and a single key' do
        it 'returns an array with the single key' do
          keys = @model.class.send :generate_keys, '1'
          keys.should == ['1']
        end
      end

      context 'and an array of keys' do
        it 'returns an array with the keys' do
          keys = @model.class.send :generate_keys, ['1', '2', '3']
          keys.should == ['1', '2', '3']
        end
      end

      context 'and a map with a single key' do
        it 'returns an array with the single key' do
          keys = @model.class.send :generate_keys, { :one => '1' }
          keys.should == ['1']
        end
      end

      context 'and a map with an array with a single key' do
        it 'returns an array with the single key' do
          keys = @model.class.send :generate_keys, { :one => ['1'] }
          keys.should == ['1']
        end
      end
    end

    context 'given a compound key model' do
      before do
        @model = CompoundKey.new
      end

      context 'and a map of keys' do
        it 'returns an array of the keys put together' do
          keys = @model.class.send :generate_keys, { :one => ['1', '2'], :two => ['a', 'b'], :three => 'Z' }
          keys.should == ['1:a:Z', '1:b:Z', '2:a:Z', '2:b:Z']
        end
      end

      context 'and a different map of keys' do
        it 'returns an array of the keys put together' do
          keys = @model.class.send :generate_keys, { :one => '1', :two => ['a', 'b'], :three => 'Z' }
          keys.should == ['1:a:Z', '1:b:Z']
        end
      end
    end

  end

end
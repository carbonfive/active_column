require 'spec_helper'

class SingleKey < ActiveColumn::Base
  keys [:one]
end

class MultipleKeys < ActiveColumn::Base
  keys [:one, :two, :three]
end

describe ActiveColumn::Base do

  describe '.generate_keys' do

    context 'given a single key part' do
      before do
        @model = SingleKey.new
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

    context 'given multiple key parts' do
      before do
        @model = MultipleKeys.new
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
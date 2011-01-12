require 'spec_helper'

def translated_comparator(given)
  cf_tasks = ActiveColumn.column_family_tasks
  cf = Cassandra::ColumnFamily.new
  cf.comparator_type = given
  cf_tasks.send(:post_process_column_family, cf).comparator_type
end

describe ActiveColumn::Tasks::ColumnFamily do

  describe '.post_process_options' do
    context 'given a time-based comparator_type' do
      it 'sets TimeUUIDType' do
        assert { translated_comparator(:time)          == 'TimeUUIDType' }
        assert { translated_comparator(:timestamp)     == 'TimeUUIDType' }
        assert { translated_comparator('TimeUUIDType') == 'TimeUUIDType' }
      end
    end

    context 'given a long-based comparator_type' do
      it 'sets LongType' do
        assert { translated_comparator(:long)      == 'LongType' }
        assert { translated_comparator('LongType') == 'LongType' }
      end
    end

    context 'given a string-based comparator_type' do
      it 'sets BytesType' do
        assert { translated_comparator(:string)     == 'BytesType' }
        assert { translated_comparator('BytesType') == 'BytesType' }
      end
    end
  end

end
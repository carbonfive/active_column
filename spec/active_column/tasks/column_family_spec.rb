require 'spec_helper'

describe ActiveColumn::Tasks::ColumnFamily do

  describe '.post_process_options' do
    context 'given a time-based comparator_type' do
      it 'sets TimeUUIDType' do
        assert { translated_comparator(:time)             == 'TimeUUIDType' }
        assert { translated_subcomparator(:time)          == 'TimeUUIDType' }
        assert { translated_comparator(:timestamp)        == 'TimeUUIDType' }
        assert { translated_subcomparator(:timestamp)     == 'TimeUUIDType' }
        assert { translated_comparator('TimeUUIDType')    == 'TimeUUIDType' }
        assert { translated_subcomparator('TimeUUIDType') == 'TimeUUIDType' }
      end
    end

    context 'given a long-based comparator_type' do
      it 'sets LongType' do
        assert { translated_comparator(:long)         == 'LongType' }
        assert { translated_subcomparator(:long)      == 'LongType' }
        assert { translated_comparator('LongType')    == 'LongType' }
        assert { translated_subcomparator('LongType') == 'LongType' }
      end
    end

    context 'given a string-based comparator_type' do
      it 'sets BytesType' do
        assert { translated_comparator(:string)        == 'BytesType' }
        assert { translated_subcomparator(:string)     == 'BytesType' }
        assert { translated_comparator('BytesType')    == 'BytesType' }
        assert { translated_subcomparator('BytesType') == 'BytesType' }
      end
    end

    context 'given a utf8-based comparator_type' do
      it 'sets UTF8Type' do
        assert { translated_comparator(:utf8)         == 'UTF8Type' }
        assert { translated_subcomparator(:utf8)      == 'UTF8Type' }
        assert { translated_comparator('UTF8Type')    == 'UTF8Type' }
        assert { translated_subcomparator('UTF8Type') == 'UTF8Type' }
      end
    end

    context 'given a lexicaluuid-based comparator_type' do
      it 'sets LexicalUUIDType' do
        assert { translated_comparator(:lexical_uuid)        == 'LexicalUUIDType' }
        assert { translated_subcomparator(:lexical_uuid)     == 'LexicalUUIDType' }
        assert { translated_comparator('LexicalUUIDType')    == 'LexicalUUIDType' }
        assert { translated_subcomparator('LexicalUUIDType') == 'LexicalUUIDType' }
      end
    end

    context 'given a standard column_type' do
      it 'sets Standard' do
        assert { translated_column_type(:standard)  == 'Standard' }
        assert { translated_column_type('Standard') == 'Standard' }
        assert { translated_column_type('standard') == 'Standard' }
      end
    end

    context 'given a super column_type' do
      it 'sets Super' do
        assert { translated_column_type(:super)  == 'Super' }
        assert { translated_column_type('Super') == 'Super' }
        assert { translated_column_type('super') == 'Super' }
      end
    end

    context 'given an invalid column type' do
      it 'raises an ArgumentError' do
        expect do
          translated_column_type(:foo)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe '.updating_column_family' do
    before do 
      @cf_tasks = ActiveColumn.column_family_tasks

      if @cf_tasks.exists?(:test_cf) 
        @cf_tasks.drop(:test_cf)
      end
      
      @cf_tasks.create(:test_cf) do |cf|
        cf.comment = "foo"
        cf.comparator_type = :long
      end
    end
    
    context "given a block of column family updates" do
      it "post process given column definitions" do
        cf_comparator_type(:test_cf).should == 'org.apache.cassandra.db.marshal.LongType'
        
        @cf_tasks.update(:test_cf) do |cf|
          cf.comparator_type = :long
        end
        cf_comparator_type(:test_cf).should == 'org.apache.cassandra.db.marshal.LongType'

      end

      it 'updates column family definitions' do
        cf_comment(:test_cf).should == "foo"
        
        @cf_tasks.update(:test_cf) do |cf|
          cf.comment = "some new comment"
        end
        
        cf_comment(:test_cf).should == "some new comment" 
      end
    end
  end

end


def cf_attr(name, attribute)
  cassandra = @cf_tasks.send(:connection)
  cf_def = cassandra.schema.cf_defs.select{|cf| cf.name == name.to_s}.first
  cf_def.send(attribute)
end

def cf_comment(name)
  cf_attr(name, :comment)
end

def cf_comparator_type(name)
  cf_attr(name, :comparator_type)
end


def translated(c, sc, ct)
  cf_tasks = ActiveColumn.column_family_tasks
  cf = Cassandra::ColumnFamily.new
  cf.comparator_type = c
  cf.subcomparator_type = sc
  cf.column_type = ct
  cf_tasks.send(:post_process_column_family, cf)
end

def translated_comparator(given)
  translated(given, nil, :standard).comparator_type
end

def translated_subcomparator(given)
  translated(nil, given, :standard).subcomparator_type
end

def translated_column_type(given)
  translated(nil, nil, given).column_type
end
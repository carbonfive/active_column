require 'spec_helper'

describe ActiveColumn::Tasks::Keyspace do

  before do
    @ks = ActiveColumn.keyspace_tasks
  end

  describe "#create" do
    context "given a keyspace" do
      before do
        @ks.drop :ks_create_test if @ks.exists?(:ks_create_test)
        @ks.create :ks_create_test
      end

      it "creates the keyspace" do
        @ks.exists?(:ks_create_test).should be
      end

      after do
        @ks.drop :ks_create_test
      end
    end
  end

  describe '#drop' do
    context 'given a keyspace' do
      before do
        @ks.create :ks_drop_test unless @ks.exists?(:ks_drop_test)
        @ks.drop :ks_drop_test
      end

      it 'drops the keyspace' do
        @ks.exists?(:ks_drop_test).should_not be
      end
    end
  end

  describe '.parse' do
    context 'given a keyspace schema as a hash' do
      before do
        @hash = { 'name' => 'ks1',
                  'cf_defs' => [ { 'name' => 'cf1', 'comment' => 'foo' },
                                 { 'name' => 'cf2', 'comment' => 'bar' } ] }
        @schema = ActiveColumn::Tasks::Keyspace.parse @hash
        @cfdefs = @schema.cf_defs.sort { |a,b| a.name <=> b.name }
      end

      it 'returns a keyspace schema' do
        @schema.should be_a(Cassandra::Keyspace)
        @schema.name.should == 'ks1'
      end

      it 'returns all column families' do
        @cfdefs.collect(&:name).should == [ 'cf1', 'cf2' ]
        @cfdefs.collect(&:comment).should == [ 'foo', 'bar' ]
      end
    end
  end

  describe '#schema_dump' do
    context 'given a keyspace' do
      before do
        cf_tasks = ActiveColumn.column_family_tasks :ks_schema_dump_test
        @ks.drop :ks_schema_dump_test if @ks.exists?(:ks_schema_dump_test)
        @ks.create :ks_schema_dump_test
        @ks.set :ks_schema_dump_test
        cf_tasks.create(:cf1) { |cf| cf.comment = 'foo' }
        cf_tasks.create(:cf2) { |cf| cf.comment = 'bar' }
        @schema = @ks.schema_dump
        @cfdefs = @schema.cf_defs.sort { |a,b| a.name <=> b.name }
      end

      it 'dumps the keyspace schema' do
        @schema.should be
        @schema.name.should == 'ks_schema_dump_test'
      end

      it 'dumps all column families' do
        @cfdefs.collect(&:name).should == [ 'cf1', 'cf2' ]
        @cfdefs.collect(&:comment).should == [ 'foo', 'bar' ]
      end

      after do
        @ks.drop :ks_schema_dump_test
      end
    end
  end

  describe '#schema_load' do
    context 'given a keyspace schema' do
      before do
        cf_tasks = ActiveColumn.column_family_tasks :ks_schema_load_test
        @ks.drop :ks_schema_load_test if @ks.exists?(:ks_schema_load_test)
        @ks.create :ks_schema_load_test
        @ks.set :ks_schema_load_test
        cf_tasks.create(:cf1) { |cf| cf.comment = 'foo' }
        cf_tasks.create(:cf2) { |cf| cf.comment = 'bar' }
        schema = @ks.schema_dump

        @ks.drop :ks_schema_load_test2 if @ks.exists?(:ks_schema_load_test2)
        @ks.create :ks_schema_load_test2
        @ks.set :ks_schema_load_test2
        @ks.schema_load schema
        @schema2 = @ks.schema_dump
        @cfdefs2 = @schema2.cf_defs.sort { |a,b| a.name <=> b.name }
      end

      it 'loads the keyspace' do
        @schema2.should be
        @schema2.name.should == 'ks_schema_load_test2'
      end

      it 'loads all column families' do
        @cfdefs2.collect(&:name).should == [ 'cf1', 'cf2' ]
        @cfdefs2.collect(&:comment).should == [ 'foo', 'bar' ]
      end

      after do
        @ks.drop :ks_schema_load_test
        @ks.drop :ks_schema_load_test2
      end
    end
  end
end

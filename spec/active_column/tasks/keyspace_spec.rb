require 'spec_helper'

describe ActiveColumn::Tasks::Keyspace do

  before do
    @ks = ActiveColumn::Tasks::Keyspace.new
    @cf = ActiveColumn::Tasks::ColumnFamily.new
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

  describe '#schema_dump' do
    context 'given a keyspace' do
      before do
        @ks.drop :ks_schema_dump_test if @ks.exists?(:ks_schema_dump_test)
        @ks.create :ks_schema_dump_test
        @ks.set :ks_schema_dump_test
        @cf.create :cf1, :keyspace => :ks_schema_dump_test.to_s, :comment => 'foo'
        @cf.create :cf2, :keyspace => :ks_schema_dump_test.to_s, :comment => 'bar'
        @schema = @ks.schema_dump
        @cfdefs = @schema.cf_defs
        @cfdefs.sort! { |a,b| a.name <=> b.name }
      end

      it 'dumps the keyspace schema' do
        @schema.should be
        @schema.name.should == 'ks_schema_dump_test'
      end

      it 'dumps all column families' do
        @cfdefs.should have(2).cfs
      end

      it 'dumps column families with correct attributes' do
        @cfdefs[0].name.should == 'cf1'
        @cfdefs[0].comment.should == 'foo'
        @cfdefs[1].name.should == 'cf2'
        @cfdefs[1].comment.should == 'bar'
      end

      after do
        @ks.drop :ks_schema_dump_test
      end
    end
  end

  describe '#keyspace_load' do
    context 'given a keyspace schema.js file' do
      before do
        @ks.drop :ks_schema_load_test if @ks.exists?(:ks_schema_load_test)
        @ks.create :ks_schema_load_test
        @ks.set :ks_schema_load_test
        @cf.create :cf1, :keyspace => :ks_schema_load_test.to_s, :comment => 'foo'
        @cf.create :cf2, :keyspace => :ks_schema_load_test.to_s, :comment => 'bar'
        schema = @ks.schema_dump

        @ks.drop :ks_schema_load_test2 if @ks.exists?(:ks_schema_load_test2)
        @ks.schema_load :ks_schema_load_test2, schema
        @ks.set :ks_schema_load_test2
        @schema2 = @ks.schema_dump
        @cfdefs2 = @schema2.cf_defs
        @cfdefs2.sort! { |a,b| a.name <=> b.name }
      end

      it 'loads the keyspace' do
        @schema2.should be
        @schema2.name.should == 'ks_schema_load_test2'
      end

      it 'loads all column families' do
        @cfdefs2.should have(2).cfs
      end

      it 'loads column families with correct attributes' do
        @cfdefs2[0].name.should == 'cf1'
        @cfdefs2[0].comment.should == 'foo'
        @cfdefs2[1].name.should == 'cf2'
        @cfdefs2[1].comment.should == 'bar'
      end

      after do
        @ks.drop :ks_schema_load_test
        @ks.drop :ks_schema_load_test2
      end
    end
  end
end

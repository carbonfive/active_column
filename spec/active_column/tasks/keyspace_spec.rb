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
        @ks.create :ks_schema_test1 unless @ks.exists?(:ks_schema_test1)
        @ks.set :ks_schema_test1
        @cf.create :cf1, :keyspace => :ks_schema_test1.to_s, :comment => 'foo'
        @cf.create :cf2, :keyspace => :ks_schema_test1.to_s, :comment => 'bar'
        @schema = @ks.schema_dump
        @cfdefs = @schema.cf_defs
        @cfdefs.sort! { |a,b| a.name <=> b.name }
      end

      it 'dumps the keyspace schema' do
        @schema.should be
        @schema.name.should == 'ks_schema_test1'
      end

      it 'the dump has all column families' do
        @cfdefs.should have(2).cfdefs
      end

      it 'the column families have correct attributes' do
        @cfdefs[0].name.should == 'cf1'
        @cfdefs[0].comment.should == 'foo'
        @cfdefs[1].name.should == 'cf2'
        @cfdefs[1].comment.should == 'bar'
      end

      after do
        @ks.drop :ks_schema_test1
      end
    end
  end
end

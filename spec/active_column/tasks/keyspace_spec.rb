require 'spec_helper'

describe ActiveColumn::Tasks::Keyspace do

  before do
    @ks = ActiveColumn::Tasks::Keyspace.new
  end

  describe ".create" do
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

  describe '.drop' do
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
end

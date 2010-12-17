require 'spec_helper'

describe ActiveColumn::KeyspaceTasks do

  describe ".create" do
    context "given an environment" do
      context "and a cassandra.yml" do
        before do
          KeyspaceTasks.create

          @keyspaces = $cassandra.keyspaces
        end
        
        it "creates the keyspace for that environment" do
          @keyspaces.should include 'active_column_development'
        end
      end
    end
  end

  describe ".create_all" do

  end

  describe '.drop' do

  end
end

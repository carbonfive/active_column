require 'spec_helper'
require 'wrong'
require 'wrong/adapters/rspec'
Wrong.config.alias_assert :expect

describe ActiveColumn::Migrator do

  migrations_path = File.expand_path("../../support/migrate", __FILE__)
  cf = ActiveColumn::Tasks::ColumnFamily.new

  describe '.migrate' do

    context 'given no previous migrations' do
      context 'and some pending migrations' do
        context 'and no target version' do
          before do
            ActiveColumn::Migrator.migrate(migrations_path)
          end

          after do
            cf.clear :schema_migrations
            cf.drop :schema_migrations
          end

          it 'creates a schema_migrations CF' do
            assert { cf.exists?(:schema_migrations) != nil }
          end

          it 'adds the migrations to the schema_migrations CF' do
            migrations = $cassandra.get(:schema_migrations, 'all').map {|name, _value| name.to_i}
            assert { migrations.length == 2 }
            assert { migrations[0] == 1 }
            assert { migrations[1] == 2 }
          end

          it 'runs the migrations' do
            assert { cf.exists?(:test1) != nil }
            assert { cf.exists?(:test2) != nil }
          end
        end

      end
    end

    context 'given some previous migrations' do

    end

  end

end
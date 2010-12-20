require 'spec_helper'
require 'wrong'
require 'wrong/adapters/rspec'
Wrong.config.alias_assert :expect

describe ActiveColumn::Migrator do

  migrations_path = File.expand_path("../../support/migrate", __FILE__)
  cf = ActiveColumn::Tasks::ColumnFamily.new

  def get_migrations
    $cassandra.get(:schema_migrations, 'all').map {|name, _value| name.to_i}
  end

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
            assert { get_migrations == [1, 2, 3, 4] }
          end

          it 'runs the migrations'

#          it 'runs the migrations' do
#            assert { cf.exists?(:test1) != nil }
#            assert { cf.exists?(:test2) != nil }
#          end
        end

        context 'and a target version up' do
          before do
            ActiveColumn::Migrator.migrate(migrations_path, 2)
          end

          after do
            cf.clear :schema_migrations
            cf.drop :schema_migrations
          end

          it 'creates a schema_migrations CF' do
            assert { cf.exists?(:schema_migrations) != nil }
          end

          it 'adds the migrations to the schema_migrations CF' do
            assert { get_migrations == [1, 2] }
          end
        end

      end

      context 'and no pending migrations' do
        before do
          ActiveColumn::Migrator.migrate(File.expand_path("..", migrations_path))
        end

        after do
          cf.clear :schema_migrations
          cf.drop :schema_migrations
        end

        it 'creates a schema_migrations CF' do
          assert { cf.exists?(:schema_migrations) != nil }
        end

        it 'adds no migrations to the schema_migrations CF' do
          assert { get_migrations == [] }
        end
      end
    end

    context 'given some previous migrations' do
      before do
        ActiveColumn::Migrator.migrate(migrations_path, 2)
      end

      after do
        cf.clear :schema_migrations
        cf.drop :schema_migrations
      end

      context 'and no target version' do
        before do
          ActiveColumn::Migrator.migrate(migrations_path)
        end

        it 'adds the migrations to the schema_migrations CF' do
          assert { get_migrations == [1, 2, 3, 4]}
        end

        it 'runs the migrations'
      end

      context 'and a target version up' do
        before do
          ActiveColumn::Migrator.migrate(migrations_path, 3)
        end

        it 'adds the migrations to the schema_migrations CF' do
          assert { get_migrations == [1, 2, 3] }
        end

        it 'runs the migrations'
      end

      context 'and a target version down' do
        before do
          ActiveColumn::Migrator.migrate(migrations_path, 1)
        end

        it 'removes the migrations from the schema_migrations CF' do
          assert { get_migrations == [1] }  
        end

        it 'rolls back the migrations'
      end
    end

  end

end
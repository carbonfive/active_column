require 'spec_helper'
require 'wrong/adapters/rspec'
Wrong.config.alias_assert :expect

module ActiveColumn
  class MigratorSpecHelper
    attr_accessor :data
    def initialize
      @data = {}
    end
  end
end

migrations_path = File.expand_path("../../support/migrate", __FILE__)
$migrator_spec_helper = ActiveColumn::MigratorSpecHelper.new

def get_migrations
  $cassandra.get(:schema_migrations, 'all').map {|name, _value| name.to_i}
end

def get_data
  $migrator_spec_helper.data.keys.sort
end

describe ActiveColumn::Migrator do

  after do
    $cassandra.truncate!("schema_migrations")
    $migrator_spec_helper.data.clear
  end

  describe '.migrate' do
    context 'given no previous migrations' do
      context 'and some pending migrations' do
        context 'and no target version' do
          before do
            ActiveColumn::Migrator.migrate(migrations_path)
          end

          it 'adds the migrations to the schema_migrations CF' do
            assert { get_migrations == [1, 2, 3, 4] }
          end

          it 'runs the migrations' do
            assert { get_data == [1, 2, 3, 4] }
          end
        end

        context 'and a target version up' do
          before do
            ActiveColumn::Migrator.migrate(migrations_path, 2)
          end

          it 'adds the migrations to the schema_migrations CF' do
            assert { get_migrations == [1, 2] }
          end

          it 'runs the migrations' do
            assert { get_data == [1, 2] }
          end
        end

      end

      context 'and no pending migrations' do
        before do
          ActiveColumn::Migrator.migrate(File.expand_path("./fake", migrations_path))
        end

        it 'adds no migrations to the schema_migrations CF' do
          assert { get_migrations == [] }
        end

        it 'runs no migrations' do
          assert { get_data == [] }
        end
      end
    end

    context 'given some previous migrations' do
      before do
        ActiveColumn::Migrator.migrate(migrations_path, 2)
      end

      context 'and no target version' do
        before do
          ActiveColumn::Migrator.migrate(migrations_path)
        end

        it 'adds the migrations to the schema_migrations CF' do
          assert { get_migrations == [1, 2, 3, 4]}
        end

        it 'runs the migrations' do
          assert { get_data == [1, 2, 3, 4]}
        end
      end

      context 'and a target version up' do
        before do
          ActiveColumn::Migrator.migrate(migrations_path, 3)
        end

        it 'adds the migrations to the schema_migrations CF' do
          assert { get_migrations == [1, 2, 3] }
        end

        it 'runs the migrations' do
          assert { get_data == [1, 2, 3] }
        end
      end

      context 'and a target version down' do
        before do
          ActiveColumn::Migrator.migrate(migrations_path, 1)
        end

        it 'removes the migrations from the schema_migrations CF' do
          assert { get_migrations == [1] }
        end

        it 'rolls back the migrations' do
          assert { get_data == [1] }
        end
      end
    end
  end

  describe '.rollback' do
    before do
      ActiveColumn::Migrator.migrate migrations_path, 3
    end

    context 'given no steps' do
      before do
        ActiveColumn::Migrator.rollback migrations_path
      end

      it 'rolls back one step' do
        assert { get_migrations == [1, 2] }
        assert { get_data       == [1, 2] }
      end
    end

    context 'given steps = 2' do
      before do
        ActiveColumn::Migrator.rollback migrations_path, 2
      end

      it 'rolls back two steps' do
        assert { get_migrations == [1] }
        assert { get_data       == [1] }
      end
    end
  end

  describe '.forward' do
    before do
      ActiveColumn::Migrator.migrate migrations_path, 1
    end

    context 'given no steps' do
      before do
        ActiveColumn::Migrator.forward migrations_path
      end

      it 'migrates one step' do
        assert { get_migrations == [1, 2] }
        assert { get_data       == [1, 2] }
      end
    end

    context 'given steps = 2' do
      before do
        ActiveColumn::Migrator.forward migrations_path, 2
      end

      it 'migrates two steps' do
        assert { get_migrations == [1, 2, 3] }
        assert { get_data       == [1, 2, 3] }
      end
    end
  end

end
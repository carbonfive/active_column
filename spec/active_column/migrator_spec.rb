require 'spec_helper'
require 'wrong'
require 'wrong/adapters/rspec'
Wrong.config.alias_assert :expect

describe ActiveColumn::Migrator do

  migrations_path = File.expand_path("../../support/migrate", __FILE__)

  def get_migrations
    $cassandra.get(:schema_migrations, 'all').map {|name, _value| name.to_i}
  end

  def drop_cf(cf)
    $cassandra.truncate!(cf.to_s)
    $cassandra.drop_column_family(cf.to_s)
  end

  def assert_cf(cf)
    cfs = $cassandra.schema.cf_defs.collect { |c| c.name }
    assert { cfs.include?(cf.to_s) }
  end

  def assert_no_cf(cf)
    cfs = $cassandra.schema.cf_defs.collect { |c| c.name }
    assert { ! cfs.include?(cf.to_s) }
  end

  def assert_rows(cf, *rows)
    rows.each do |row|
      assert { $cassandra.get(cf, row.to_s).length == 1 }
    end
  end

  def assert_no_rows(cf, *rows)
    rows.each do |row|
      assert { $cassandra.get(cf, row.to_s).length == 0 }
    end
  end

  describe '.migrate' do

    after do
      $cassandra.truncate!("schema_migrations")
    end

    context 'given no previous migrations' do
      context 'and some pending migrations' do
        context 'and no target version' do
          before do
            ActiveColumn::Migrator.migrate(migrations_path)
          end

          after do
            drop_cf :test1
          end

          it 'adds the migrations to the schema_migrations CF' do
            assert { get_migrations == [1, 2, 3, 4] }
          end

          it 'runs the migrations' do
            assert_cf :test1
            assert_rows :test1, 1, 2, 3
          end
        end

        context 'and a target version up' do
          before do
            ActiveColumn::Migrator.migrate(migrations_path, 2)
          end

          after do
            drop_cf :test1
          end

          it 'adds the migrations to the schema_migrations CF' do
            assert { get_migrations == [1, 2] }
          end

          it 'runs the migrations' do
            assert_cf :test1
            assert_rows :test1, 1
          end
        end

      end

      context 'and no pending migrations' do
        before do
          ActiveColumn::Migrator.migrate(File.expand_path("..", migrations_path))
        end

        it 'adds no migrations to the schema_migrations CF' do
          assert { get_migrations == [] }
        end

        it 'runs no migrations' do
          assert_no_cf :test1
        end
      end
    end

    context 'given some previous migrations' do
      before do
        ActiveColumn::Migrator.migrate(migrations_path, 2)
      end

      after do
        drop_cf :test1
      end

      context 'and no target version' do
        before do
          ActiveColumn::Migrator.migrate(migrations_path)
        end

        it 'adds the migrations to the schema_migrations CF' do
          assert { get_migrations == [1, 2, 3, 4]}
        end

        it 'runs the migrations' do
          assert_cf :test1
          assert_rows :test1, 1, 2, 3
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
          assert_cf :test1
          assert_rows :test1, 1, 2
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
          assert_cf :test1
          assert_no_rows :test1, 1
        end
      end
    end

  end

end
require 'rails/generators'
require 'rails/generators/named_base'

module ActiveColumn
  module Generators
    class MigrationGenerator < Rails::Generators::NamedBase

      source_root File.expand_path("../templates", __FILE__)

      def self.banner
        "rails g active_column:migration NAME"
      end

      def self.desc(description = nil)
<<EOF
Description:
  Create an empty Cassandra migration file in 'ks/migrate'.  Very similar to Rails database migrations.

Example:
  `rails g active_column:migration CreateFooColumnFamily`
EOF
      end

      def create
        timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
        template 'migration.rb.erb', "ks/migrate/#{timestamp}_#{file_name.tableize}.rb"
      end

    end
  end
end
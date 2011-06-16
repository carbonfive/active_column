require 'rails_generator/base'

class KsMigrationGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      m.directory 'ks/migrate'
      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      m.template 'migration.rb.erb', "ks/migrate/#{timestamp}_#{file_name.underscore}.rb"
    end
  end

  def banner
    "Usage: ./script/generate ks_migration NAME [options]"
  end

end

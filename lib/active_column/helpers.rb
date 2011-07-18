module ActiveColumn
  module Helpers

    def self.current_env
      ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def current_env
      ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def testing?
      self.current_env == 'test'
    end

    def log(msg, e = nil)
      puts msg if e || !testing?
      p e if e
      nil
    end

  end
end

class Object
  def to_json(*a)
    result = {
      JSON.create_id => self.class.name
    }
    instance_variables.inject(result) do |r, name|
      r[name[1..-1]] = instance_variable_get name
      r
    end
    result.to_json(*a)
  end
end
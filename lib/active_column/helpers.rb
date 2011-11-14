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

if ! defined? String.tableize
class String
  def tableize
    t = self.dup.to_s
    t += ( t =~ /s$/ ? 'es' : 's' )
    t.gsub!(/::/, '/')
    t.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    t.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    t.tr!("-", "_")
    t.downcase!
    t
  end
end
end
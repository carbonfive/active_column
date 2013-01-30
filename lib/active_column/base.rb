module ActiveColumn

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def column_family(column_family = nil)
      return @column_family || self.name.tableize.to_sym if column_family.nil?
      @column_family = column_family
    end

    def key(key, options = {})
      @keys ||= []
      @keys << KeyConfig.new(key, options)
    end

    def keys
      @keys
    end

    def find(key_parts, options = {})
      keys = generate_keys key_parts
      ActiveColumn.connection.multi_get(column_family, keys, options).each_with_object( {} ) do |(user, row), results|
        results[user] = row.to_a.collect { |(_uuid, col)| new(JSON.parse(col)) }
      end
    end

    def generate_keys(key_parts)
      if keys.size == 1
        key_config = keys.first
        value = key_parts.is_a?(Hash) ? key_parts[key_config.key] : key_parts
        return value if value.is_a? Array
        return [value]
      end

      values = keys.collect { |kc| key_parts[kc.key] }
      product = values.reduce do |memo, key_part|
        memo     = [memo]     unless memo.is_a? Array
        key_part = [key_part] unless key_part.is_a? Array
        memo.product key_part
      end

      product.collect { |p| p.join(':') }
    end

  end

  def initialize(attrs = {})
    attrs.each do |attr, value|
      send("#{attr}=", value) if respond_to?("#{attr}=")
    end
  end

  def save
    value = { SimpleUUID::UUID.new.to_s => self.to_json }
    keys.each do |key|
      ActiveColumn.connection.insert(self.class.column_family, key, value)
    end

    return self
  end

  def delete
    value = { SimpleUUID::UUID.new.to_s => self.to_json }
    keys.each do |key|
      ActiveColumn.connection.remove(self.class.column_family, key, value)
    end
  end

  def keys
    key_parts = self.class.keys.each_with_object( {} ) do |key_config, key_parts|
      key_parts[key_config.key] = self.send(key_config.func)
    end
    keys = self.class.generate_keys(key_parts)
  end  

  class Base
    include ActiveColumn
  end

end


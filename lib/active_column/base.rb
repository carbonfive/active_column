module ActiveColumn

  class Base

    # @column_family = self.class.name.pluralize.downcase
    @column_family = nil  # todo: should we bring in ActiveSupport *just* for #pluralize ?
    @keys = []

    attr_reader :attributes

    def initialize(attrs = {})
      @attributes = attrs
    end

    def self.column_family(column_family = nil)
      return @column_family if column_family.nil?
      @column_family = column_family
    end

    def self.keys(keys = nil)
      return @keys if keys.nil?
      @keys = keys
    end

    def save(key_parts)
      value = { SimpleUUID::UUID.new => @attributes.to_json }
      keys = self.class.generate_keys(key_parts)

      keys.each do |key|
        ActiveColumn.connection.insert(self.class.column_family, key, value)
      end

      self
    end

    def self.find(key_parts, options = {})
      keys = generate_keys key_parts
      ActiveColumn.connection.multi_get(column_family, keys, options)
    end

    def to_json(*a)
      @attributes.to_json(*a)
    end

    private

    def self.generate_keys(key_parts)
      if keys.size == 1
        part = keys.first
        value = key_parts.is_a?(Hash) ? key_parts[part] : key_parts
        return value if value.is_a? Array
        return [value]
      end

      values = keys.collect { |k| key_parts[k] }
      product = values.reduce do |memo, key_part|
        memo     = [memo]     unless memo.is_a? Array
        key_part = [key_part] unless key_part.is_a? Array
        memo.product key_part
      end

      product.collect { |p| p.join(':') }
    end

  end

end
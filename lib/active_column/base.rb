module ActiveColumn

  class Base

    attr_reader :attributes

    # @column_family = self.class.name.pluralize.downcase
    @column_family = nil  # todo: should we bring in ActiveSupport *just* for #pluralize ?
    @keys = []

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

    def self.create(attrs = {})
      self.new attrs
    end

    def save(parts)
      value = { SimpleUUID::UUID.new => @attributes.to_json }
      keys = self.class.generate_keys(parts)

      keys.each do |key|
        ActiveColumn.connection.insert(self.class.column_family, key, value)
      end

      self
    end

    def self.find(parts, options = {})
      keys = generate_keys parts
      ActiveColumn.connection.multi_get(column_family, keys, options)
    end

    def to_json(*a)
      @attributes.to_json(*a)
    end

    private

    def self.generate_keys(parts)
      if keys.size == 1
        part = keys.first
        value = parts.is_a?(Hash) ? parts[part] : parts
        return value if value.is_a? Array
        return [value]
      end

      values = keys.collect { |k| parts[k] }
      product = values.reduce do |memo, part|
        memo = [memo] unless memo.is_a? Array
        part = [part] unless part.is_a? Array
        memo.product part
      end

      product.collect { |p| p.join(':') }
    end

  end

end
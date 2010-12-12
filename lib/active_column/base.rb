module ActiveColumn

  class Base

    attr_reader :attributes

    def initialize(attrs = {})
      @attributes = attrs
    end

    def self.column_family(column_family = nil)
      return @column_family if column_family.nil?
      @column_family = column_family
    end

    def self.keys(*keys)
      return @keys if keys.nil? || keys.empty?
      flattened = ( keys.size == 1 && keys[0].is_a?(Array) ? keys[0] : keys )
      @keys = flattened.collect { |k| KeyConfig.new(k) }
    end

    def save()
      value = { SimpleUUID::UUID.new => self.to_json }
      key_parts = self.class.keys.each_with_object( {} ) do |key_config, key_parts|
        key_parts[key_config.key] = get_keys(key_config)
      end
      keys = self.class.generate_keys(key_parts)

      keys.each do |key|
        ActiveColumn.connection.insert(self.class.column_family, key, value)
      end

      self
    end

    def self.find(key_parts, options = {})
      keys = generate_keys key_parts
      ActiveColumn.connection.multi_get(column_family, keys, options).each_with_object( {} ) do |(user, row), results|
        results[user] = row.to_a.collect { |(_uuid, col)| new(JSON.parse(col)) }
      end
    end

    def to_json(*a)
      @attributes.to_json(*a)
    end

    private

    def get_keys(key_config)
      key_config.func.nil? ? attributes[key_config.key] : self.send(key_config.func)
    end

    def self.generate_keys(key_parts)
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

  class KeyConfig
    attr_accessor :key, :func

    def initialize(key_conf)
      if key_conf.is_a?(Hash)
        @key = key_conf.keys[0]
        @func = key_conf[@key]
      else
        @key = key_conf
      end
    end

    def to_s
      "KeyConfig[#{key}, #{func or '-'}]"
    end
  end

end
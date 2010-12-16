module ActiveColumn

  class KeyConfig
    attr_accessor :key, :func

    def initialize(key, options)
      @key = key
      @func = options[:values] || key
    end

    def to_s
      "KeyConfig[#{key}, #{func or '-'}]"
    end
  end
  
end
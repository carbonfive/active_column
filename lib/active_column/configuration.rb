module ActiveColumn

  module Configuration

    def configurations
      @@configurations
    end

    def configuration=(configurations)
      @@configurations = configurations
    end

    def config(env = Rails.env)
      configurations[env || 'development']
    end

    def connection
      @@connection
    end

    def connection=(connection)
      @@connection = connection
    end

  end

end

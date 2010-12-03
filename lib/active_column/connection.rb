module ActiveColumn

  module Connection

    def connection
      @@connection
    end

    def connection=(connection)
      @@connection = connection
    end

  end

end

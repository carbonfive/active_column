class Tweet
  include ActiveColumn

  key :user_id

  attr_accessor :user_id, :message

end
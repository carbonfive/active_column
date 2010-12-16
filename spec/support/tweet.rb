class Tweet < ActiveColumn::Base

  column_family :tweets
  key :user_id

  attr_accessor :user_id, :message

end
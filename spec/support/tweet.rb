class Tweet < ActiveColumn::Base

  column_family :tweets
  keys :user_id

end
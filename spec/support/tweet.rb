class Tweet < ActiveColumn::Base

  column_family :tweets
  key :user_id

end
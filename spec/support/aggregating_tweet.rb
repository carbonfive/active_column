class AggregatingTweet < ActiveColumn::Base

  column_family :tweets
  keys :user_id => :user_keys

  def user_keys
    [ attributes[:user_id], 'all' ]
  end

end
class AggregatingTweet < ActiveColumn::Base

  column_family :tweets
  key :user_id, :values => :user_keys

  def user_keys
    [ attributes[:user_id], 'all' ]
  end

end
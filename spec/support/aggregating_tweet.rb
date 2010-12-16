class AggregatingTweet < ActiveColumn::Base

  column_family :tweets
  key :user_id, :values => :user_keys

  attr_accessor :user_id, :message

  def user_keys
    [ user_id, 'all' ]
  end

end
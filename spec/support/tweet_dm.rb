class TweetDM < ActiveColumn::Base

  column_family :tweet_dms
  keys [ { :user_id => :user_keys }, { :recipient_id => :recipient_keys } ]

  def user_keys
    [ attributes[:user_id], 'all' ]
  end

  def recipient_keys
    attributes[:recipient_ids] + ['all']
  end

end
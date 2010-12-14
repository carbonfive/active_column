class TweetDM < ActiveColumn::Base

  column_family :tweet_dms
  key :user_id,      :values => :user_keys
  key :recipient_id, :values => :recipient_keys

  def user_keys
    [ attributes[:user_id], 'all' ]
  end

  def recipient_keys
    attributes[:recipient_ids] + ['all']
  end

end
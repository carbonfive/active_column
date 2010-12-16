class TweetDM
  include ActiveColumn

  key :user_id,      :values => :user_keys
  key :recipient_id, :values => :recipient_keys

  attr_accessor :user_id, :recipient_ids, :message

  def user_keys
    [ user_id, 'all' ]
  end

  def recipient_keys
    recipient_ids + ['all']
  end

end
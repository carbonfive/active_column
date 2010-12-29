### Saving data

To make a model in to an ActiveColumn model, just extend ActiveColumn::Base, and provide two pieces of information:

- Column Family (optional)
- Function(s) to generate keys for your rows of data

If you do not specify a column family, it will default to the "tabelized" class name, just like ActiveRecord.
Example: Tweet --> tweets
Example: TweetDM --> tweet_dms

The most basic form of using ActiveColumn looks like this:
<pre>
class Tweet &lt; ActiveColumn::Base
  key :user_id
  attr_accessor :user_id, :message
end
</pre>

Note that you can also use ActiveColumn as a mix-in, like this:
<pre>
class Tweet
  include ActiveColumn

  key :user_id
  attr_accessor :user_id, :message
end
</pre>

Then in your app you can create and save a tweet like this:
<pre>
tweet = Tweet.new( :user_id => 'mwynholds', :message => "I'm going for a bike ride" )
tweet.save
</pre>

When you run #save, ActiveColumn saves a new column in the "tweets" column family in the row with key "mwynholds".  The
content of the row is the Tweet instance JSON-encoded.

*Key Generator Functions*

This is great, but quite often you want to save the content in multiple rows for the sake of speedy lookups.  This is
basically de-normalizing data, and is extremely common in Cassandra data.  ActiveColumn lets you do this quite easily
by telling it the name of a function to use to generate the keys during a save.  It works like this:

<pre>
class Tweet
  include ActiveColumn

  key :user_id, :values => :generate_user_keys
  attr_accessor :user_id, :message

  def generate_user_keys
    [ user_id, 'all']
  end
end
</pre>

The code to save the tweet is the same as the previous example, but now it saves the tweet in both the "mwynholds" row
and the "all" row.  This way, you can pull out the last 20 of all tweets quite easily (assuming you needed to do this
in your app).

*Compound Keys*

In some cases you may want to have your rows keyed by multiple values.  ActiveColumn supports compound keys,
and looks like this:

<pre>
class TweetDM
  include ActiveColumn

  column_family :tweet_dms
  key :user_id,      :values => :generate_user_keys
  key :recipient_id, :values => :recipient_ids
  attr_accessor :user_id, :recipient_ids, :message

  def generate_user_keys
    [ user_id, 'all ]
  end
end
</pre>

Now, when you create a new TweetDM, it might look like this:

<pre>
dm = TweetDM.new( :user_id => 'mwynholds', :recipient_ids => [ 'fsinatra', 'dmartin' ], :message => "Let's go to Vegas" )
</pre>

This tweet direct message will saved to four different rows in the "tweet_dms" column family, under these keys:

- mwynholds:fsinatra
- mwynholds:dmartin
- all:fsinatra
- all:dmartin

Now my app can pretty easily figure find all DMs I sent to Old Blue Eyes, or to Dino, and it can also easily find all
DMs sent from *anyone* to Frank or Dino.

One thing to note about the TweetDM class above is that the "keys" configuration at the top looks a little uglier than
before.  If you have a compound key and any of the keys have custom key generators, you need to pass in an array of
single-element hashes.  This is in place to support Ruby 1.8, which does not have ordered hashes.  Making sure the keys
are ordered is necessary to keep the compounds keys canonical (ie: deterministic).
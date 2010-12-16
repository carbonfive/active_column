# ActiveColumn

ActiveColumn is a framework for saving and retrieving data from Cassandra in a "time line" model.  It is loosely based
on concepts in ActiveRecord, but is adapted to saving data in which rows in Cassandra grow indefinitely over time, such
as in the oft-used Twitter example for Cassandra.

## Installation

Add ActiveColumn to your Gemfile:
<pre>
gem 'active_column'
</pre>

Install with bundler:
<pre>
bundle install
</pre>

## Usage

### Configuration

ActiveColumn requires the [cassandra gem](https://github.com/fauna/cassandra).  You must provide ActiveColumn with an
instance of a Cassandra object.  You can do this very simply like this:

<pre>
ActiveColumn.connection = Cassandra.new('my_keyspace', '127.0.0.1:9160')
</pre>

However, in a real app this is not flexible enough, so I often create a cassandra.yml file and configure Cassandra in an
initializer.

config/cassandra.yml
<pre>
test:
  home: ":"
  servers: "127.0.0.1:9160"
  keyspace: "myapp_test"
  thrift:
    timeout: 3
    retries: 2

development:
  home: ":"
  servers: "127.0.0.1:9160"
  keyspace: "myapp_development"
  thrift:
    timeout: 3
    retries: 2
</pre>

config/initializers/cassandra.rb
<pre>
config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))[Rails.env]
$cassandra = Cassandra.new(config['keyspace'],
                           config['servers'],
                           config['thrift'])

ActiveColumn.connection = $cassandra
</pre>

As you can see, I create a global $cassandra variable, which I use in my tests to validate data directly in Cassandra.

One other thing to note is that you obviously must have Cassandra installed and running!  Please take a look at the
[mama_cass gem](https://github.com/carbonfive/mama_cass) for a quick way to get up and running with Cassandra for
development and testing.

### Saving data

To make a model in to an ActiveColumn model, just extend ActiveColumn::Base, and provide two pieces of information:

- Column Family
- Function(s) to generate keys for your rows of data

The most basic form of using ActiveColumn looks like this:
<pre>
class Tweet &lt; ActiveColumn::Base
  column_family :tweets
  key :user_id

  attr_accessor :user_id, :message
end
</pre>

Note that you can also use ActiveColumn as a mix-in, like this:
<pre>
class Tweet
  include ActiveColumn

  column_family :tweets
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
class Tweet &lt; ActiveColumn::Base
  column_family :tweets
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
class TweetDM &lt; ActiveColumn::Base
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

### Finding data

Ok, congratulations - now you have a bunch of fantastic data in Cassandra.  How do you get it out?  ActiveColumn can
help you here too.

Here is how you look up data that have a simple key:

<pre>
tweets = Tweet.find( 'mwynholds', :reversed => true, :count => 3 )
</pre>

This code will find the last 10 tweets for the 'mwynholds' user in reverse order.  It comes back as a hash of arrays,
and would looks like this if represented in JSON:

<pre>
{
  'mwynholds': [ { 'user_id': 'mwynholds', 'message': 'I\'m going to bed now' },
                 { 'user_id': 'mwynholds', 'message': 'It\'s lunch time' },
                 { 'user_id': 'mwynholds', 'message': 'Just woke up' } ]
}
</pre>

Here are some other examples and their return values:

<pre>
Tweet.find( [ 'mwynholds', 'all' ], :count => 2 )

{
  'mwynholds': [ { 'user_id': 'mwynholds', 'message': 'Good morning' },
                 { 'user_id': 'mwynholds', 'message': 'Good afternoon' } ],
  'all': [ { 'user_id': 'mwynholds', 'message': 'Good morning' },
             'user_id': 'bmurray', 'message': 'Who ya gonna call!' } ]
}
</pre>

<pre>
Tweet.find( { 'user_id' => 'all', 'recipient_id' => [ 'fsinatra', 'dmartin' ] }, :reversed => true, :count => 1 )

{
  'all:fsinatra' => [ { 'user_id': 'mwynholds', 'recipient_ids' => [ 'fsinatra', 'dmartin' ], 'message' => 'Here we come Vegas!' } ],
  'all:dmartin' => [ { 'user_id': 'fsinatra', 'recipient_ids' => [ 'dmartin' ], 'message' => 'Vegas was fun' } ]
}
</pre>
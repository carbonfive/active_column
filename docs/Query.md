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
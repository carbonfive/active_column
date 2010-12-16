require 'spec_helper'

describe ActiveColumn::Base do

  describe '#save' do

    context 'given a model with a single key' do
      before do
        @counter = Counter.new(:tweets, 'user1', 'user2', 'all')
      end

      context 'and an attribute key function' do
        before do
          Tweet.new( user_id: 'user1', message: 'just woke up' ).save
          Tweet.new( user_id: 'user2', message: 'kinda hungry' ).save
        end

        it 'saves the model for the key' do
          @counter.diff.should == [1, 1, 0]
        end
      end

      context 'and an attribute key function (via mixin)' do
        before do
          TweetMix.new( user_id: 'user1', message: 'just woke up' ).save
          TweetMix.new( user_id: 'user2', message: 'kinda hungry' ).save
        end

        it 'saves the model for the key' do
          @counter.diff.should == [1, 1, 0]
        end
      end

      context 'and a custom key function' do
        before do
          AggregatingTweet.new( user_id: 'user1', message: 'just woke up' ).save
          AggregatingTweet.new( user_id: 'user2', message: 'kinda hungry' ).save
        end

        it 'saves the model for the keys' do
          @counter.diff.should == [1, 1, 2]
        end
      end
    end

    context 'given a model with a compound key' do
      before do
        @counts = Counter.new(:tweet_dms, 'user1:friend1', 'user1:friend2', 'user1:all', 'all:friend1', 'all:friend2')
        TweetDM.new( user_id: 'user1', recipient_ids: ['friend1', 'friend2'], message: 'feeling blue' ).save
        TweetDM.new( user_id: 'user1', recipient_ids: ['friend2'], message: 'now im better' ).save
      end

      it 'saves the model for the combined compounds keys' do
        @counts.diff.should == [1, 2, 2, 1, 2]
      end
    end

  end

  describe '.generate_keys' do

    context 'given a simple key model' do
      before do
        @model = SimpleKey.new
      end

      context 'and a single key' do
        it 'returns an array with the single key' do
          keys = @model.class.send :generate_keys, '1'
          keys.should == ['1']
        end
      end

      context 'and an array of keys' do
        it 'returns an array with the keys' do
          keys = @model.class.send :generate_keys, ['1', '2', '3']
          keys.should == ['1', '2', '3']
        end
      end

      context 'and a map with a single key' do
        it 'returns an array with the single key' do
          keys = @model.class.send :generate_keys, { :one => '1' }
          keys.should == ['1']
        end
      end

      context 'and a map with an array with a single key' do
        it 'returns an array with the single key' do
          keys = @model.class.send :generate_keys, { :one => ['1'] }
          keys.should == ['1']
        end
      end
    end

    context 'given a compound key model' do
      before do
        @model = CompoundKey.new
      end

      context 'and a map of keys' do
        it 'returns an array of the keys put together' do
          keys = @model.class.send :generate_keys, { :one => ['1', '2'], :two => ['a', 'b'], :three => 'Z' }
          keys.should == ['1:a:Z', '1:b:Z', '2:a:Z', '2:b:Z']
        end
      end

      context 'and a different map of keys' do
        it 'returns an array of the keys put together' do
          keys = @model.class.send :generate_keys, { :one => '1', :two => ['a', 'b'], :three => 'Z' }
          keys.should == ['1:a:Z', '1:b:Z']
        end
      end
    end

  end

end
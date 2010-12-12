require 'spec_helper'

describe ActiveColumn::Base do

  describe '.find' do

    context 'given a model with a simple key' do
      before do
        Tweet.new( :user_id => 'user1', :message => 'Going running' ).save
        Tweet.new( :user_id => 'user2', :message => 'Watching TV' ).save
        Tweet.new( :user_id => 'user1', :message => 'Now im hungry' ).save
        Tweet.new( :user_id => 'user1', :message => 'Now im full' ).save
      end

      context 'and finding some for a single key' do
        before do
          @found = Tweet.find( 'user1', :count => 3, :reversed => true )
        end

        it 'find all of the models' do
          @found.size.should == 1
          @found['user1'].size.should == 3
          @found['user1'].collect { |t| t.attributes['message'] }.should == [ 'Now im full', 'Now im hungry', 'Going running' ]
        end
      end

      context 'and finding some for multiple keys' do
        before do
          @found = Tweet.find( ['user1', 'user2'], :count => 1, :reversed => true )
        end

        it 'finds all of the models' do
          @found.size.should == 2
          @found['user1'].collect { |t| t.attributes['message'] }.should == [ 'Now im full' ]
          @found['user2'].collect { |t| t.attributes['message'] }.should == [ 'Watching TV' ]
        end
      end
    end

    context 'given a model with a compound key' do
      before do
        TweetDM.new( :user_id => 'user1', :recipient_ids => [ 'friend1', 'friend2' ], :message => 'Need to do laundry' ).save
        TweetDM.new( :user_id => 'user1', :recipient_ids => [ 'friend2', 'friend3' ], :message => 'My leg itches' ).save
      end

      context 'and finding some for both keys' do
        before do
          @found = TweetDM.find( { :user_id => ['user1', 'user2'], :recipient_id => ['friend1', 'friend2', 'all'] }, :count => 1, :reversed => true )
        end

        it 'finds all of the models' do
          @found.size.should == 6
          @found['user1:friend1'].collect { |t| t.attributes['message'] }.should == [ 'Need to do laundry' ]
          @found['user1:friend2'].collect { |t| t.attributes['message'] }.should == [ 'My leg itches' ]
          @found['user1:all'].collect { |t| t.attributes['message'] }.should == [ 'My leg itches' ]
          @found['user2:friend1'].should == []
          @found['user2:friend2'].should == []
          @found['user2:all'].should == []
        end
      end
    end

  end
  
end
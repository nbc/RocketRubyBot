# coding: utf-8
$:.unshift File.expand_path('../lib', __dir__)

require 'rocket-ruby-bot'
require_relative 'simple_vote/simple_vote'

RocketRubyBot.configure do |config|
  config.url    = 'http://localhost:3000'
  config.user   = 'mybot'
  config.digest  = '2e6669346178ab7d3edb94d7141082c0ba481e52a21d94ac422c6b68a99b34fc' # mybot
end

RocketRubyBot::UserStore.configure do |user_store|
  user_store.room_name = 'general'
  user_store.default_time = 300
end

class SimpleVoteBot < RocketRubyBot::Bot
  setup do |client|
    SimpleVote.bot_name = config.user

    # we subscribe to all group we are in
    subscriptions = client.get_subscriptions
    subscriptions.update.each do |canal|
      client.say stream_room_messages(room_id: canal.rid)
    end

    # we subscribe to stream to known when we are added to group
    client.say stream_notify_user(user_id: config.user_id, sub: 'subscriptions-changed')
  end

  # we subscribe to group when we are added to
  on_event :subscriptions_changed do |client, data|
    room_id = data.added_to_group
    next unless room_id
    client.say stream_room_messages(room_id: room_id)
  end
  
  command 'vote create' do |client, message, _match|
    msg = SimpleVote.create_vote(message.user.username, message.room_id, message.msg)
    client.say send_message room_id: message.room_id, msg: msg

    # we set a timer to close the vote
    EM.add_timer(user_store.default_time) do
      vote = SimpleVote.find_vote(message.room_id)
      next unless vote

      msg = SimpleVote.close(vote.user, message.room_id)
      client.say send_message room_id: message.room_id, msg: msg
    end
  end

  command('vote show') do |client, message, _match|
    vote = SimpleVote.find_vote(message.room_id)
    msg = vote.message
    client.say send_message room_id: message.room_id, msg: msg
  end

  command('vote close') do |client, message, _match|
    msg = SimpleVote.close(message.user.username, message.room_id)
    client.say send_message(room_id: message.room_id, msg: msg)
  end

  command('vote') do |client, message, _match|
    vote = SimpleVote.find_vote(message.room_id)
    msg = vote.vote_for(message.user.username, message.msg)
    client.say send_message room_id: message.room_id, msg: msg
  end
end

SimpleVoteBot.run

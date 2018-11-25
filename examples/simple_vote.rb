# coding: utf-8
$:.unshift File.expand_path('../lib', __dir__)

require 'rocket-ruby-bot'
require_relative 'simple_vote/vote'

RocketRubyBot.configure do |config|
  config.url    = 'http://localhost:3000'
  config.user   = 'mybot'
  config.digest  = '2e6669346178ab7d3edb94d7141082c0ba481e52a21d94ac422c6b68a99b34fc' # mybot
end

RocketRubyBot::UserStore.configure do |user_store|
  user_store.room_name = 'general'
  user_store.default_time = 10
end

class VoteBot < RocketRubyBot::Bot
  setup do |client|
    # we subscribe to all group we are in
    client.say get_subscriptions do |message|
      message.result.update.each do |canal|
        client.say stream_room_messages(room_id: canal.rid)
      end
    end

    # we subscribe to stream to known when we are added to group
    client.say stream_notify_user(user_id: config.user_id, sub: 'subscriptions-changed')
  end

  # we subscribe to group when we are added to
  on_event :subscriptions_changed do |client, data|
    room_id = data.added_to_group?
    client.say stream_room_messages(room_id: room_id) if room_id
  end
  
  command 'create vote' do |client, message, _match|
    msg = Vote.create_vote(message.user.username, message.room_id, message.msg)
    client.say send_message room_id: message.room_id, msg: msg

    # we set a timer to close the vote
    EM.add_timer(user_store.default_time) do
      vote = Vote.vote(message.room_id)
      next unless vote

      msg = Vote.close(vote.user, message.room_id)
      client.say send_message room_id: message.room_id, msg: msg
    end
  end

  command('vote') do |client, message, _match|
    vote = Vote.vote(message.room_id)
    if vote
      msg = vote.voice(message.user.username, message.msg)
    else
      msg = 'pas de vote en cours'
    end
    client.say send_message room_id: message.room_id, msg: msg
  end

  command('show vote') do |client, message, _match|
    vote = Vote.vote(message.room_id)
    if vote
      msg = vote.message
    else
      msg = 'pas de vote en cours'
    end
    client.say send_message room_id: message.room_id, msg: msg
  end
  
  command('close vote') do |client, message, _match|
    vote = Vote.vote(message.room_id)
    if vote
      msg = Vote.close(message.user.username, message.room_id)
    else
      msg = 'pas de vote en cours'
    end
    client.say send_message(room_id: message.room_id, msg: msg)
  end
end

VoteBot.run

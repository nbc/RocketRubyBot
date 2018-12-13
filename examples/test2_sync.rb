# coding: utf-8
path = File.expand_path( File.join( File.dirname( __FILE__) , "..", "lib"))
$:.unshift path

require 'rocket-ruby-bot'
require 'ap'

RocketRubyBot.configure do |config|
  config.url    = 'http://localhost:3000'
  config.user   = 'mybot'
  config.digest  = '2e6669346178ab7d3edb94d7141082c0ba481e52a21d94ac422c6b68a99b34fc' # mybot
end

RocketRubyBot::UserStore.configure do |user_store|
  # user_store.room_name = 'general'
  user_store.room_name = 'unautrecanal'
end

class TestBot < RocketRubyBot::Bot
  setup do |client|
    message = client.sync_say get_room_id(room: user_store.room_name)

    user_store.room_id = message.result

    # pp client.say set_presence status: 'online'
    # client.sync_say stream_room_messages room_id: user_store.room_id
    client.sync_say stream_notify_user user_id: config.user_id, sub: 'rooms-changed'
    client.sync_say stream_notify_user user_id: config.user_id, sub: 'notification'
    client.sync_say stream_notify_user user_id: config.user_id, sub: 'subscriptions-changed'
    client.sync_say stream_notify_all sub: 'roles-change'
    client.sync_say stream_notify_all sub: 'permissions-changed'
    client.sync_say stream_notify_all sub: 'updateAvatar'
    client.sync_say stream_notify_logged sub: 'updateAvatar'
  end

  on_event :user_rooms_changed, :user_subscriptions_changed, :user_notification do |client, data|
    pp data
  end
end

TestBot.run

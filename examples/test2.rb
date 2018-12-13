# coding: utf-8
path = File.expand_path( File.join( File.dirname( __FILE__) , "..", "lib"))
$:.unshift path

require 'rocket-ruby-bot'

RocketRubyBot.configure do |config|
  config.url    = 'http://localhost:3000'
  config.user   = 'mybot'
  config.digest  = '2e6669346178ab7d3edb94d7141082c0ba481e52a21d94ac422c6b68a99b34fc' # mybot
end

RocketRubyBot::UserStore.configure do |user_store|
  user_store.room_name = 'general'
end

class TestBot < RocketRubyBot::Bot
  setup do |client|
    client.say get_room_id(room: user_store.room_name) do |message|
      user_store.room_id = message.result
      client.say set_presence status: 'online'
      client.say stream_notify_user user_id: config.user_id, sub: 'rooms-changed'
      # client.say stream_notify_user user_id: config.user_id, sub: 'subscriptions-changed'
      message = client.sync_say stream_notify_user user_id: config.user_id, sub: 'notification'
      pp message
      
      # pp web_client.users.info username: 'nicolas'
      
      # client.say stream_notify_user user_id: 'BATd9C33CdKGRbRf4', sub: 'subscriptions-changed'
      
    end
  end
end

TestBot.run

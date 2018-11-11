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

class PongBot < RocketRubyBot::Bot
  setup do |client|
    client.say get_room_id(room: user_store.room_name) do |message|
      user_store.room_id = message.result
      client.say sub_stream_room_messages(room_id: user_store.room_id)
    end
  end

  command 'ping' do |client, message, match|
    client.say send_message(room_id: message.rid, msg: "pong")
  end
end

PongBot.run

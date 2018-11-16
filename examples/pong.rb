# coding: utf-8
$:.unshift File.expand_path('../lib', __dir__)

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
  # subscribe to new messages in the general room
  setup do |client|
    client.say get_room_id(room: user_store.room_name) do |mess|
      user_store.room_id = mess.result
      client.say stream_room_messages(room_id: user_store.room_id)
    end
  end

  # reply pong to "mybot ping"
  command 'ping' do |client, message, _match|
    client.say send_message(room_id: message.rid, msg: "pong")
  end

  # reply pong to "! ping"
  match(/!\s*ping/) do |client, message, _match|
    client.say send_message(room_id: message.rid, msg: "pong")
  end
end

PongBot.run

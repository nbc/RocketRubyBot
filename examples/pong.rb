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
    ret = client.get_room_id(room: user_store.room_name)
    client.stream_room_messages(room_id: ret.room_id)
  end

  # reply pong to "mybot ping"
  command 'ping' do |client, message, _match|
    client.send_message(room_id: message.rid, msg: "pong")
  end

  # reply pong to "! ping"
  match(/!\s*ping/) do |client, message, _match|
    client.send_message(room_id: message.rid, msg: "pong")
  end
end

PongBot.run

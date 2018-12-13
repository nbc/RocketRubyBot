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
      client.say sub_stream_room_messages(room_id: user_store.room_id)

      pp web_client.channels.delete(name: 'test3')
      pp web_client.groups.delete(name: 'test3')
      
      name = "a#{uuid}"
      client.say register_user username: name, name: name, email: "#{name}@localhost.com", pass: name do |m|
        pp m
      end

      client.say create_private_group name: 'test3', users: ['af970c80a3c116f2997d1f754350eaaed', 'nicolas'] do |m|
        pp m
      end
      
      client.say create_direct_message username: config.user do |message|
        room_id = message.result.rid
        client.say send_message room_id: room_id, msg: "test"
      end

    end
  end
end

TestBot.run

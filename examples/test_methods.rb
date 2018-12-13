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

    client.say 
    
  end

end

TestBot.run

Rocket-Ruby-Bot

## Features

A very crude and ill documented RocketChat ruby bot framework

## Disclaimer

I code for fun, I'm not and will never be a good developer.

## Simple bot

#### Gemfile

```ruby
source 'https://rubygems.org'

gem 'rocket-ruby-bot', :git => 'https://github.com/nbc/rocket-ruby-bot.git'
```

#### pongbot.rb

```ruby
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
      client.say stream_room_messages(room_id: user_store.room_id)
    end
  end

  command 'ping' do |client, message, match|
    client.say send_message(room_id: message.rid, msg: "pong")
  end
end

PongBot.run
```
To run it, just do :

```ruby
ROCKET_API_TOKEN=<my_token> ruby examples/pong.rb
 ```

To get your token you can use curl :

```
curl -H "Content-type:application/json" \
      https://rocket-chat-url/api/v1/login \
      -d '{ "username": "<username>", "password": "<password>" }'
```


## Commands

### on_event

The most low level command is `on\_event :event\_type`. With it you can access all types of event

```ruby
on_event :authenticated do |client, data|
	# ...
end
```

`client` is used to speak with the server
`data` is the data return by the event.

You can find an events list in doc/events.md

### setup

`setup` is just syntactic sugar around `on_event :authenticated`. You can use it to handle subscription or say hello

### command

`command` allow you to wait for commands on channel/room.

```ruby
command 'ping' do |client, message, match|
  client.say send_message(room_id: message.rid, msg: "pong")
end
```

`match` has 3 named captures :
* bot : bot name
* command : command name
* text : text after the command name

### match

`match` allow lower level interaction.

```ruby
match /!duck\s+(?<text>\S.*)/ do |client, message, match|
  # some code to search on duckduckgo
end
```


### say

`say` is used to send message to Rocket.Chat.

If called without a block, it just send data :

```ruby
  client.say send_message(message_id: uuid, room_id: room_id, msg: "pong")
```

If you want to do something with the server response, you can call `client.say` with a block :

```ruby
client.say get_room_id(room: "room_name") do |message|
  user_store.room_id = message.result
  client.say sub_stream_room_messages(room_id: user_store.room_id)
end
```

or use `sync_say` that serialize answer :

```ruby
res = client.sync_say get_room_id(room: "room_name")
user_store.room_id = res.result
client.say sub_stream_room_messages(room_id: user_store.room_id)
```


when authenticated, ask the server for the room's id wait for the answer and send a `stream_room_messages` subscription for this room.

In this case, a rest call to get the `room_id` is perhaps a simplier solution:

```ruby
on_event :authenticated do |client, data|
  group = web_client.groups.info(name: "room_name")
  client.say sub_stream_room_messages(room_id: group.id)
end
```


### environment

You have access to 2 useful methods in your bot:

* `web_client` a fully fonctionnal `RocketChat::Session` already logged to do REST interaction. See https://github.com/abrom/rocketchat-ruby for documentation
* `user_store` to store things. It's a hash and `Hashie::Mash` subclass so you can use keys as methods to access value.

  ```ruby
  user_store.my_value
  user_store['my_value']
  ```

## Inspiration

Thanks to the following projects, I've been able to understand a little bit better the Rocket.Chat realtime API
https://bitbucket.org/EionRobb/purple-rocketchat
https://github.com/mathieui/unha2/blob/master/docs/methods.rst

Thanks to slack-ruby-bot, I've been able to produce a little less awful code
https://github.com/slack-ruby/slack-ruby-bot/

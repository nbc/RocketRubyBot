Rocket-Ruby-Bot

## Features

A very crude and ill documented RocketChat ruby bot framework

## Disclaimer

I code for fun, I can't assure you of anything

## Simple bot

#### Gemfile

```ruby
source 'https://rubygems.org'

gem 'rocket-ruby-bot', :git => 'https://github.com/nbc/rocket-ruby-bot.git'
```

#### pongbot.rb

```ruby
path = File.expand_path ( File.join( File.dirname( __FILE__) , "..", "lib") )
$:.unshift path

require 'rocket-ruby-bot'

RocketRubyBot.configure do |config|
  config.url    = 'https://your.rocket.chat.url'
  config.user   = 'mybot'
end

RocketRubyBot::UserStore.configure do |user_store|
  user\_store.room_name = 'my\_room'
end

class PongBot < RocketRubyBot::Bot

  on_event :authenticated do |client, data|
    client.say get_room_id(room: user_store.room_name) do |message|
      user_store.room_id = message.result
      client.say sub_stream_room_messages(room_id: user_store.room_id)
    end
  end

  on_message %r<mybot ping> do |client, message, match|
    client.say send_message(message_id: uuid, room_id: user_store.room_id, msg: "pong")
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
`data` is the data return in the event.

You can find a list in doc/events.md

### on_message

`on_message` allow you to wait for message on channel/room.

```ruby
on_message %r<mybot ping> do |client, message, match|
  ...
end
```

### say

`say` is used to send message to Rocket.Chat.

If called without a block, it just send information :

```ruby
  client.say send_message(message_id: uuid, room_id: room_id, msg: "pong")
```

If you want to do something with the server response, you can call `client.say` with a block :

```ruby
on_event :authenticated do |client, data|
  client.say get_room_id(room: "room_name") do |message|
    user_store.room_id = message.result
    client.say sub_stream_room_messages(room_id: user_store.room_id)
  end
end
```

when authenticated, ask the server for the id of room\_name, wait for the answer and send a stream\_room\_messages subscription for this room.

In this case, a rest call to get the room\_id is perhaps a simplier solution:

```ruby
on_event :authenticated do |client, data|
  group = web_client.groups.info(name: "room_name")
  client.say sub_stream_room_messages(room_id: group.id)
end
```


### environment

You have access to 2 useful methods in your bot:

* web_client a fully fonctionnal RocketChat::Session already logged to do REST interaction. See https://github.com/abrom/rocketchat-ruby for documentation
* user_store to ... store things. user_store a hash object. As it's a Hashie::Mash subclass, you can use keys as methods to access value.

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

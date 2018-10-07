Rocket-Ruby-Bot

## Features

A very crude and ill documented Rocket Chat ruby bot framework

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


```



To get your token you can use 

```
curl -H "Content-type:application/json" \
      https://rocket-chat-url/api/v1/login \
      -d '{ "username": "<username>", "password": "<password>" }'
```

```ruby
ROCKET_API_TOKEN=<my_token> ruby bin/rie-bot.rb
 ```

## 

Commands you can use

* command :event_type
* message /regexp/

You have access to :

* web_client a fully fonctionnal RocketChat::Session already logged to do REST interaction. See https://github.com/abrom/rocketchat-ruby for documentation
* user_store to ... store things. user_store a hash object. As it's a Hashie subclass, you can also use keys as methods to access value.

## Inspiration

Thanks to the following project, I've been able to understand a little bit better the RocketChat realtime API
https://bitbucket.org/EionRobb/purple-rocketchat
https://github.com/mathieui/unha2/blob/master/docs/methods.rst

Thanks to slack-ruby-bot, I've been able to produce a little less awful code
https://github.com/slack-ruby/slack-ruby-bot/

# events

Those are the events you can subscribe to with the `on_event` command.

```ruby
  # we subscribe to group when we are added to
  on_event :subscriptions_changed do |client, data|
    room_id = data.added_to_group?
    client.say stream_room_messages(room_id: room_id) if room_id
  end
```

## simple events
list of events
* `:connected` : return on server connection
* `:ready` : returned on subscription (`stream_room_messages`...)
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/
* `:updated`
* `:removed`
* `:failed`
* `:error`
* `:added`
* `:ping` : ping from server, automatically handled by the ping hook


## `results` events

Those events are returned in response of a bot command.

There's two types :

* `:authenticated`
  returned on successful login
  https://rocket.chat/docs/developer-guides/realtime-api/method-calls/login/
* `:result`
  event returned for all requests except authentication
  example : https://rocket.chat/docs/developer-guides/realtime-api/method-calls/get-user-roles/
  ...


## `changed` events

Those events are send when you subscribe to a stream
https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/

### `stream-room-messages` stream

All events on a room.

https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-room-messages/
* `:room_message` : new message, event on message (reactions...)
* `:room_join`
* `:room_left`
* `:room_added`
* `:room_removed`
* `:room_muted`
* `:room_unmuted`
* `:room_role_added`
* `:room_role_removed`
* `:room_changed_topic`

### `stream-notify-user` stream

All events arriving to your bot.

* `:user_notification` : direct message or message with @yourname or @all
* `:user_rooms_changed` : new or updated message
* `:user_subscriptions_changed` : added to a group or removed from a group

See https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-user/

### `stream-notify-all` stream

General user-wide stream.

See : https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-all/

### `stream-notify-logged` stream

Stream for logged users

https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-logged/

### `stream-notify-room` stream
* `:typing`
* `:delete_message`

# Sources

For information on events, you can
https://bitbucket.org/EionRobb/purple-rocketchat
https://github.com/mathieui/unha2/blob/master/docs/methods.rst

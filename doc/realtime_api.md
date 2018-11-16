# Method calls
https://rocket.chat/docs/developer-guides/realtime-api/method-calls/
parameters not yet documented. Read lib/rocket-ruby-bot/realtime/api.rb
* `login`
* `room_roles`
  * `room_id:`
* `get_subscriptions`
  * `since:` timestamp
* `get_rooms`
  * `since:` timestamp
* `get_permissions`
* `set_presence`
* `create_direct_message`
* `create_channel`
* `create_private_group`
* `erase_room`
* `archive_room`
* `unarchive_room`
* `join_channel`
* `leave_room`
* `hide_room`
* `open_room`
* `send_message`
* `load_history`
* `send_pong`
methods found in https://github.com/mathieui/unha2/blob/master/docs/methods.rst
* `get_room_id`
  get room id by name or id
* `channels_list`
* `get_users_of_room`
  * `room_id:`
  * `offline_users:` true/false
* `read_messages`
# Subscriptions
* `stream_notify_all`
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-all/
* `stream-notify-logged`
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-logged/
* `stream-notify-user`
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-user/

  ```
  ["{\"msg\":\"sub\",\"id\":\"j3rDKZiswk48oD3xq\",\"name\":\"stream-notify-user\",\"params\":[\"hZKg86uJavE6jYLya/notification\",false]}"]
  ["{\"msg\":\"sub\",\"id\":\"BhQGCDSHbs2K8b6Qo\",\"name\":\"stream-notify-user\",\"params\":[\"oAKZSpTPTQHbp6nBD/rooms-changed\",false]}"]
  ["{\"msg\":\"sub\",\"id\":\"2wA7uGgSRcw67DsqW\",\"name\":\"stream-notify-user\",\"params\":[\"oAKZSpTPTQHbp6nBD/subscriptions-changed\",false]}"]
  ["{\"msg\":\"sub\",\"id\":\"d7R5u6pCkLKPfxFa7\",\"name\":\"stream-notify-user\",\"params\":[\"oAKZSpTPTQHbp6nBD/otr\",false]}"]
  ```
* `stream-notify-room-users`
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-room-users/
  bug in documentation
* `stream_notify_room`
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-room/
* `stream_room_message`
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-room-messages/

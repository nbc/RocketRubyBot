# events
list of events
* `:connected`
  return on server connection
* `:ready`
  returned on subscription (`stream_room_messages`...)
  https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/
* `:updated`
* `:removed`
* `:failed`
* `:error`
* `:ping` : ping from server, automatically handled by the ping hook
## `results` events
* `:authenticated`
  returned on successful login
  https://rocket.chat/docs/developer-guides/realtime-api/method-calls/login/
  `:authenticated`
* `:result`
  event returned for all requests except authentication
  example : https://rocket.chat/docs/developer-guides/realtime-api/method-calls/get-user-roles/
  ...
## `added` events
* `:added_user`
* `:added`
## `changed` events
### `stream-room-messages` events
https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-room-messages/
* `:message` : new message, event on message (reactions...)
* `:user_join` : user join room
* `:user_left` : user left room
* `:added_user` : user added to room
* `:remove_user` : user removed from room
* `:user_muted`
* `:user_unmuted`
* `:subscription_role_removed`
* `:subscription_role_added`
* `:room_changed_topic`
### `stream-notify-user` events
https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-user/
* `:notification`
* `:rooms_changed`
* `:self_inserted` : self added to room
* `:self_removed` : self removed from room
* `:self_updated` : self updated (new role, owner...)
* `:inserted` user added to a new room
* `:updated` : something change in room, topic, announcement...
* `:otr`
## `stream-notify-room` events
* `:typing`
* `:delete_message`
# Sources
For information on events, you can
https://bitbucket.org/EionRobb/purple-rocketchat
https://github.com/mathieui/unha2/blob/master/docs/methods.rst

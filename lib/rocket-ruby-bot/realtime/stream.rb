module RocketRubyBot
  module Realtime
    # implements methods calls from
    # https://rocket.chat/docs/developer-guides/realtime-api/method-calls/
    module Stream

      def included(base)
        base.extend self
      end
      extend self

      ArgumentNotAllowed = Class.new(StandardError)
      #=
      #= # Subscriptions
      #=

      #= * `stream_notify_all`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-all/
      ALLOWED_NOTIFY_ALL = %w[roles-change updateEmojiCustom deleteEmojiCustom
                              updateAvatar public-settings-changed permissions-changed].freeze
      def stream_notify_all(sub:)
        argument_is_in(ALLOWED_NOTIFY_ALL, sub)
        { msg: 'sub',
          name: 'stream-notify-all',
          params: [sub, false] }
      end

      #= * `stream-notify-logged`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-logged/
      #=
      ALLOWED_NOTIFY_LOGGED = %w[Users:NameChanged Users:Deleted updateAvatar
                                 updateEmojiCustom deleteEmojiCustom roles-change].freeze
      def stream_notify_logged(sub:)
        argument_is_in(ALLOWED_NOTIFY_LOGGED, sub)
        { msg: 'sub',
          name: 'stream-notify-logged',
          params: [sub, false] }
      end

      #= * `stream-notify-user`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-user/
      #= 
      #=   ```
      #= ["{"msg":"sub","id":"j3rDKZiswk48oD3xq","name":"stream-notify-user",
      #=                "params":["hZKg86uJavE6jYLya/notification",false]}"]
      #= ["{"msg":"sub","id":"BhQGCDSHbs2K8b6Qo","name":"stream-notify-user",
      #=                "params":["oAKZSpTPTQHbp6nBD/rooms-changed",false]}"]
      #= ["{"msg":"sub","id":"2wA7uGgSRcw67DsqW","name":"stream-notify-user",
      #=                "params":["oAKZSpTPTQHbp6nBD/subscriptions-changed",false]}"]
      #= ["{"msg":"sub","id":"d7R5u6pCkLKPfxFa7","name":"stream-notify-user",
      #=                "params":["oAKZSpTPTQHbp6nBD/otr",false]}"]
      #=   ```
      #=
      ALLOWED_USER_SUBS = %w[notification rooms-changed
                             subscriptions-changed otr webrtc message].freeze
      def stream_notify_user(user_id:, sub:)
        argument_is_in(ALLOWED_USER_SUBS, sub)

        { msg: 'sub',
          name: 'stream-notify-user',
          params: [format('%s/%s', user_id, sub), false] }
      end

      #= * `stream-notify-room-users`
      #=
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-room-users/
      #=   bug in documentation
      ALLOWED_NOTIFY_ROOM_USERS = %w[webrtc].freeze
      def stream_notify_room_users(room_id:, sub:)
        argument_is_in(ALLOWED_NOTIFY_ROOM_USERS, sub)
        { msg: 'sub',
          name: 'stream-notify-room-users',
          params: [format('%s/%s', room_id, sub), false] }
      end

      #= * `stream_notify_room`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-room/
      ALLOWED_NOTIFY_ROOM = %w[deleteMessage typing].freeze
      def stream_notify_room(room_id:, sub:)
        argument_is_in(ALLOWED_NOTIFY_ROOM, sub)

        { msg: 'sub',
          name: 'stream-notify-room',
          params: [format('%s/%s', room_id, sub), false] }
      end

      #= * `stream_room_message`
      #=
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-room-messages/
      #=
      def stream_room_messages(room_id:)
        { msg: 'sub',
          name: 'stream-room-messages',
          params: [room_id, false] }
      end

      private

      def argument_is_in(allowed, arg)
        raise ArgumentNotAllowed, "should be in [#{allowed.join(' ')}]" \
          unless allowed.include? arg
      end
    end
  end
end

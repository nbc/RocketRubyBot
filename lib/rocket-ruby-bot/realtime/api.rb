require_relative '../utils'

module RocketRubyBot
  module Realtime
    module API
      include RocketRubyBot::UUID
      extend self

      class ArgumentNotAllowed < StandardError; end
      
      #= # Method calls

      #= https://rocket.chat/docs/developer-guides/realtime-api/method-calls/
      #=
      #= parameters not yet documented. Read lib/rocket-ruby-bot/realtime/api.rb
      
      #= * `login`
      def login(options)
        if options.has_key? :digest and options.has_key? :username
          return {msg: 'method',
                  method: 'login',
                  params: [{ user: { username: options[:username] },
                             password: { digest: options[:digest], algorithm: "sha-256" }}]}
        elsif options.has_key? :token
          return {msg: "method",
                  method: "login",
                  params: [ { resume: options[:token] }]}
        else
          raise ArgumentError, "should have (digest and username) or token"
        end
      end

      def register_user
        # FIXME
      end

      def get_user_roles
        # FIXME
      end

      def get_public_settings
        # FIXME
      end
      
      #=
      #= * `get_users_or_room`
      #=   * `room_id:`
      #=   * `offline_users:` true/false
      
      def get_users_of_room(room_id: , offline_users: false)
        {msg: 'method',
         method: 'getUsersOfRoom',
         params: [ room_id, offline_users]
        }
      end

      #= * `room_roles`
      #=   * `room_id:`
      def room_roles(room_id:)
        {msg: "method",
         method: "getRoomRoles",
         params: [room_id]
        }
      end

      #= * `get_subscriptions`
      #=   * `since:` timestamp
      def get_subscriptions(since: 0)
        {msg: "method",
         method: "subscriptions/get",
         params: [ { '$date': since } ]
        }
      end
      
      #= * `get_rooms`
      #=   * `since:` timestamp
      def get_rooms(since: 0)
        {msg: 'method',
         method: 'rooms/get',
         params: [{'$date': since}]
        }
      end

      #= * `get_permissions`
      def get_permissions
        {msg: "method",
         method: "permissions/get",
         params: []
        }
      end

      #= * `set_presence`
      ALLOWED_STATUS = %w[online busy away offline].freeze
      def set_presence(status:)
        verify_argument(ALLOWED_STATUS, status)

        {msg: "method",
         method: "UserPresence:setDefaultStatus",
         params: [status]}
      end

      #= * `create_direct_message`
      def create_direct_message(username:)
        {msg: "method",
         method: "createDirectMessage",
         params: [username]
        }
      end

      #= * `create_channel`
      def create_channel(name:, users: [], read_only:)
        raise ArgumentNotAllowed, "users: must be an array" unless users.is_a? Array
        {msg: "method",
         method: "createChannel",
         params: [ name, users, read_only ]
        }
      end

      #= * `create_private_group`
      def create_private_group(name:, users: [])
        raise ArgumentNotAllowed, "users: must be an array" unless users.is_a? Array
        {msg: "method",
         method: "createPrivateGroup",
         params: [name, users]
        }
      end

      #= * `erase_room`
      def erase_room(room_id:)
        {msg: "method",
         method: "eraseRoom",
         params: [ room_id ]
        }
      end

      #= * `archive_room`
      def archive_room(room_id:)
        {msg: "method",
         method: "archiveRoom",
         params: [ room_id ]
        }
      end

      #= * `unarchive_room`
      def unarchive_room(room_id:)
        {msg: "method",
         method: "unarchiveRoom",
         params: [ room_id ]
        }
      end

      #= * `join_channel`
      def join_channel(room_id:, join_code: false)
        params = join_code ? [room_id, join_code] : [room_id]

        {msg: "method",
         method: "joinRoom",
         params: params
        }
      end

      #= * `leave_room`
      def leave_room(room_id:)
        {msg: "method",
         method: "leaveRoom",
         params: [ room_id]
        }
      end

      #= * `hide_room`
      def hide_room(room_id:)
        {msg: "method",
         method: "hideRoom",
         params: [ room_id ]
        }
      end

      #= * `open_room`
      def open_room(room_id:)
        {msg: "method",
         method: "openRoom",
         params: [ room_id ]
        }
      end
      
      #= * `send_message`
      def send_message(room_id:, msg:, message_id: uuid)
        {msg: 'method',
         method: 'sendMessage',
         'params': [{message_id: message_id, rid: room_id, msg: msg}]}
      end

      #= * `load_history`
      def load_history(room_id:, limit: 50, msg_before: "null", last_received: 0)
        {msg: "method",
         method: "loadHistory",
         params: [ room_id, msg_before, 50, { '$date': last_received } ]
        }
      end

      #= * `send_pong`
      def send_pong
        {msg: 'pong'}
      end

      #= 
      #= methods found in https://github.com/mathieui/unha2/blob/master/docs/methods.rst
      #=
      
      #= * `get_room_id`
      #=   get room id by name or id
      def get_room_id(room:)
        {msg: "method",
         method: "getRoomIdByNameOrId",
         params: [room]}
      end

      #= * `channels_list`
      ALLOWED_CHANNEL = %w[public private].freeze
      ALLOWED_SORT    = %w[name msgs].freeze
      def channels_list(filter: "", type: "public", sort_by: "name", limit: 500)
        verify_argument(ALLOWED_CHANNEL, type)
        verify_argument(ALLOWED_SORT, sort_by)

        {msg: "method",
         method: "channelsList",
         params: [filter, type, limit, sort_by]}
      end

      #= * `get_users_of_room`
      def get_users_of_room(room_id:, user_status: "true")
        {msg: "method",
         method: "getUsersOfRoom",
         params: [room_id, user_status]}
      end

      #= * `read_messages`
      def read_messages
        {msg: "method",
         method: "readMessages",
         params: []}
      end

      #= 
      #= # Subscriptions
      #= 

      #= * `stream_notify_all`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-all/
      ALLOWED_NOTIFY_ALL = %w[roles-change updateEmojiCustom deleteEmojiCustom updateAvatar public-settings-changed permissions-changed].freeze
      def sub_stream_notify_all(sub:)
        verify_argument(ALLOWED_NOTIFY_ALL, sub)
        {msg: "sub",
         name: "stream-notify-all",
         params:[sub, false]}
      end

      #= * `stream-notify-logged`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-logged/
      #= 
      ALLOWED_NOTIFY_LOGGED = %w[Users:NameChanged Users:Deleted updateAvatar updateEmojiCustom deleteEmojiCustom roles-change].freeze
      def sub_stream_notify_logged(sub:)
        verify_argument(ALLOWED_NOTIFY_LOGGED, sub)
        {msg: "sub",
         name: "stream-notify-logged",
         params:[sub, false]}
      end

      #= * `stream-notify-user`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-user/
      #= 
      #=   ```
      #=   ["{\"msg\":\"sub\",\"id\":\"j3rDKZiswk48oD3xq\",\"name\":\"stream-notify-user\",\"params\":[\"hZKg86uJavE6jYLya/notification\",false]}"]
      #=   ["{\"msg\":\"sub\",\"id\":\"BhQGCDSHbs2K8b6Qo\",\"name\":\"stream-notify-user\",\"params\":[\"oAKZSpTPTQHbp6nBD/rooms-changed\",false]}"]
      #=   ["{\"msg\":\"sub\",\"id\":\"2wA7uGgSRcw67DsqW\",\"name\":\"stream-notify-user\",\"params\":[\"oAKZSpTPTQHbp6nBD/subscriptions-changed\",false]}"]
      #=   ["{\"msg\":\"sub\",\"id\":\"d7R5u6pCkLKPfxFa7\",\"name\":\"stream-notify-user\",\"params\":[\"oAKZSpTPTQHbp6nBD/otr\",false]}"]
      #=   ```
      #= 
      ALLOWED_USER_SUBS = %w[notification rooms-changed subscriptions-changed otr webrtc message].freeze
      def sub_stream_notify_user(user_id:, sub:)
        verify_argument(ALLOWED_USER_SUBS, sub)

        { msg: 'sub',
          name: 'stream-notify-user',
          params: [ '%s/%s' % [user_id, sub], false ]
        }
      end

      #= * `stream-notify-room-users`
      #= 
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-room-users/
      #=   bug in documentation
      ALLOWED_NOTIFY_ROOM_USERS = %w[webrtc].freeze
      def sub_stream_notify_room_users(room_id:, sub:)
        verify_argument(ALLOWED_NOTIFY_ROOM_USERS, sub)
        {msg: "sub",
         name: "stream-notify-room-users",
         params: ["%s/%s" % [room_id, sub], false]
        }
      end
      
      #= * `stream_notify_room`
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-room/
      ALLOWED_NOTIFY_ROOM = %w[deleteMessage typing].freeze
      def sub_stream_notify_room(room_id:, sub:)
        verify_argument(ALLOWED_NOTIFY_ROOM, sub)

        { msg: 'sub',
          name: 'stream-notify-room',
          params: [ '%s/%s' % [room_id, sub], false ]
        }
      end

      #= * `stream_room_message`
      #= 
      #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-room-messages/
      #= 
      def sub_stream_room_messages(room_id:)
        {msg: "sub",
         name: "stream-room-messages",
         params: [room_id, false]}
      end


      private
      
      def verify_argument(allowed, arg)
        raise ArgumentNotAllowed, "should be in [#{allowed.join(" ")}]" unless allowed.include? arg
      end

    end
  end
end

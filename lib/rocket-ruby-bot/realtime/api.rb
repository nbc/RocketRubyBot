require_relative '../utils'

module RocketRubyBot
  module Realtime
    module API
      extend self

      class ArgumentNotAllowed < StandardError; end
      
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

      def get_users(room_id: , offline_users: false)
        {msg: 'method',
         method: 'getUsersOfRoom',
         params: [ room_id, offline_users]
        }
      end

      def room_roles(room_id:)
        {msg: "method",
         method: "getRoomRoles",
         params: [room_id]
        }
      end

      def get_subscription(last_time: 0)
        {msg: "method",
         method: "subscriptions/get",
         params: [ { '$date': last_time } ]
        }
      end
      
      def get_rooms(last_time: 0)
        {msg: 'method',
         method: 'rooms/get',
         params: [{'$date': last_time}]
        }
      end

      def get_permissions
        {msg: "method",
         method: "permissions/get",
         params: []
        }
      end

      ALLOWED_STATUS = %w[online busy away offline].freeze
      def set_presence(status:)
        verify_argument(ALLOWED_STATUS, status)

        {msg: "method",
         method: "UserPresence:setDefaultStatus",
         params: [status]}
      end

      def create_direct_message(username:)
        {msg: "method",
         method: "createDirectMessage",
         params: [username]
        }
      end

      def create_channel(channel_name:, users: [], read_only:)
        raise ArgumentNotAllowed, "users: must be an array" unless users.is_a? Array
        {msg: "method",
         method: "createChannel",
         params: [ channel_name, users, read_only ]
        }
      end

      def create_private_group(channel_name:, users: [])
        raise ArgumentNotAllowed, "users: must be an array" unless users.is_a? Array
        {msg: "method",
         method: "createPrivateGroup",
         params: [channel_name, users]
        }
      end

      def erase_room(room_id:)
        {msg: "method",
         method: "eraseRoom",
         params: [ room_id ]
        }
      end

      def archive_room(room_id:)
        {msg: "method",
         method: "archiveRoom",
         params: [ room_id ]
        }
      end

      def unarchive_room(room_id:)
        {msg: "method",
         method: "unarchiveRoom",
         params: [ room_id ]
        }
      end

      def join_channel(room_id:, join_code: false)
        params = join_code ? [room_id, join_code] : [room_id]

        {msg: "method",
         method: "joinRoom",
         params: params
        }
      end

      def leave_room(room_id:)
        {msg: "method",
         method: "leaveRoom",
         params: [ room_id]
        }
      end

      def hide_room(room_id:)
        {msg: "method",
         method: "hideRoom",
         params: [ room_id ]
        }
      end

      def open_room(room_id:)
        {msg: "method",
         method: "openRoom",
         params: [ room_id ]
        }
      end
      
      
      def send_message(room_id:, msg:, message_id: uuid)
        message_id ||= uuid
        {msg: 'method',
         method: 'sendMessage',
         'params': [{message_id: message_id, rid: room_id, msg: msg}]}
      end

      def load_history(room_id:, limit: 50, msg_before: "null", last_received: 0)
        {msg: "method",
         method: "loadHistory",
         params: [ room_id, msg_before, 50, { '$date': last_received } ]
        }
      end

      def send_pong
        {msg: 'pong'}
      end
      
      def sub_stream_room_messages(room_id:)
        {msg: "sub",
         name: "stream-room-messages",
         params: [room_id, false]}
      end

      ALLOWED_NOTIFY_ALL = %w[roles-change updateEmojiCustom deleteEmojiCustom updateAvatar public-settings-changed permissions-changed].freeze
      def sub_stream_notify_all(sub:)
        verify_argument(ALLOWED_NOTIFY_ALL, sub)
        {msg: "sub",
         name: "stream-notify-all",
         params:[sub, false]}
      end


      ALLOWED_NOTIFY_LOGGED = %w[Users:NameChanged Users:Deleted updateAvatar updateEmojiCustom deleteEmojiCustom roles-change].freeze
      def sub_stream_notify_logged(sub:)
        verify_argument(ALLOWED_NOTIFY_LOGGED, sub)
        {msg: "sub",
         name: "stream-notify-logged",
         params:[sub, false]}
      end

      ALLOWED_USER_SUBS = %w[notification rooms-changed subscriptions-changed otr webrtc message].freeze
      def sub_stream_notify_user(user_id:, sub:)
        verify_argument(ALLOWED_USER_SUBS, sub)

        { msg: 'sub',
          name: 'stream-notify-user',
          params: [ '%s/%s' % [user_id, sub], false ]
        }
      end

      # methods found at https://github.com/mathieui/unha2/blob/master/docs/methods.rst
      
      def get_room_id(room:)
        {msg: "method",
         method: "getRoomIdByNameOrId",
         params: [room]}
      end

      ALLOWED_CHANNEL = %w[public private].freeze
      ALLOWED_SORT    = %w[name msgs].freeze
      def get_channels_list(filter: "", type: "public", sort_by: "name", limit: 500)
        verify_argument(ALLOWED_CHANNEL, type)
        verify_argument(ALLOWED_SORT, sort_by)

        {msg: "method",
         method: "channelsList",
         params: [filter, type, limit, sort_by]}
      end
      
      def get_users_of_room(room_id:, user_status: "true")
        {msg: "method",
         method: "getUsersOfRoom",
         params: [room_id, user_status]}
      end

      def read_messages
        {msg: "method",
         method: "readMessages",
         params: []}
      end

      private
      
      def verify_argument(allowed, arg)
        raise ArgumentNotAllowed, "should be in [#{allowed.join(" ")}]" unless allowed.include? arg
      end

    end
  end
end

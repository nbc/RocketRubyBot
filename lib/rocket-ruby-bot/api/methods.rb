require_relative '../utils/helper'

module RocketRubyBot
  module API
    # implements methods calls from
    # https://rocket.chat/docs/developer-guides/realtime-api/method-calls/
    module Methods
      include RocketRubyBot::Utils::UUID
      
      def included(base)
        base.extend self
      end
      extend self

      ArgumentNotAllowed = Class.new(StandardError)

      #= # Method calls
      #=
      #= https://rocket.chat/docs/developer-guides/realtime-api/method-calls/
      #=
      #= parameters not yet documented. Read lib/rocket-ruby-bot/realtime/api.rb
      
      #= * `login`
      def login(options)
        if options[:token]
          login_with_token token: options[:token]
          
        elsif options[:digest] && options[:username]
          login_with_username username: options[:username],
                              digest: options[:digest]
        else
          raise ArgumentError, 'should have (digest and username) or token'
        end
      end

      def login_with_username(username:, digest:)
        { msg: 'method', method: 'login',
          params: [{ user: { username: username },
                     password: { digest: digest, algorithm: 'sha-256' } }] }
      end

      def login_with_token(token:)
        { msg: 'method', method: 'login',
          params: [{ resume: token }] }
      end
      
      # doesn't work 
      # https://github.com/RocketChat/Rocket.Chat/issues/11890
      def register_user(email:, pass:, name:, secret_url: false)
        params = { email: email,
                   pass: pass,
                   name: name }
        params[:secretURL] = secret_url if secret_url
        
        { msg: 'method',
          method: 'registerUser',
          params: [params] }
      end

      def get_user_roles
        { msg: 'method',
          method: 'getUserRoles',
          params: [] }
      end

      def get_public_settings
        { msg: 'method',
          method: 'public-settings/get' }
      end
      
      #= * `room_roles`
      #=   * `room_id:`
      def room_roles(room_id:)
        { msg: 'method',
          method: 'getRoomRoles',
          params: [room_id] }
      end

      #= * `get_subscriptions`
      #=   * `since:` timestamp
      def get_subscriptions(since: 0)
        { msg: 'method',
          method: 'subscriptions/get',
          params: [{ '$date': since }] }
      end
      
      #= * `get_rooms`
      #=   * `since:` timestamp
      def get_rooms(since: 0)
        { msg: 'method',
          method: 'rooms/get',
          params: [{ '$date': since }] }
      end

      #= * `get_permissions`
      def get_permissions
        { msg: 'method',
          method: 'permissions/get',
          params: [] }
      end

      #= * `set_presence`
      ALLOWED_STATUS = %w[online busy away offline].freeze
      def set_presence(status:)
        argument_is_in(ALLOWED_STATUS, status)

        { msg: 'method',
          method: 'UserPresence:setDefaultStatus',
          params: [status] }
      end

      #= * `create_direct_message`
      def create_direct_message(username:)
        { msg: 'method',
          method: 'createDirectMessage',
          params: [username] }
      end

      def verify_array_of_users(users)
        raise ArgumentNotAllowed, 'users: must be an array' unless users.is_a? Array
      end
      
      #= * `create_channel`
      def create_channel(name:, users: [], read_only: false)
        verify_array_of_users(users)

        { msg: 'method',
          method: 'createChannel',
          params: [name, users, read_only] }
      end

      #= * `create_private_group`
      def create_private_group(name:, users: [])
        verify_array_of_users(users)

        { msg: 'method',
          method: 'createPrivateGroup',
          params: [name, users] }
      end

      #= * `erase_room`
      def erase_room(room_id:)
        { msg: 'method',
          method: 'eraseRoom',
          params: [room_id] }
      end

      #= * `archive_room`
      def archive_room(room_id:)
        { msg: 'method',
          method: 'archiveRoom',
          params: [room_id] }
      end

      #= * `unarchive_room`
      def unarchive_room(room_id:)
        { msg: 'method',
          method: 'unarchiveRoom',
          params: [room_id] }
      end

      #= * `join_channel`
      def join_channel(room_id:, join_code: false)
        params = join_code ? [room_id, join_code] : [room_id]

        { msg: 'method',
          method: 'joinRoom',
          params: params }
      end

      #= * `leave_room`
      def leave_room(room_id:)
        { msg: 'method',
          method: 'leaveRoom',
          params: [room_id] }
      end

      #= * `hide_room`
      def hide_room(room_id:)
        { msg: 'method',
          method: 'hideRoom',
          params: [room_id] }
      end

      #= * `open_room`
      def open_room(room_id:)
        { msg: 'method',
          method: 'openRoom',
          params: [room_id] }
      end
      
      #= * `send_message`
      def send_message(room_id:, msg:, message_id: uuid)
        { msg: 'method',
          method: 'sendMessage',
          'params': [{ message_id: message_id, rid: room_id, msg: msg }] }
      end

      #= * `load_history`
      def load_history(room_id:, limit: 50, msg_before: nil, last_received: 0)
        { msg: 'method',
          method: 'loadHistory',
          params: [room_id, msg_before, limit, { '$date': last_received }] }
      end

      #=
      #= methods found in https://github.com/mathieui/unha2/blob/master/docs/methods.rst
      #=
      
      #= * `get_room_id`
      #=   get room id by name or id
      def get_room_id(room:)
        { msg: 'method',
          method: 'getRoomIdByNameOrId',
          params: [room] }
      end

      #= * `channels_list`
      ALLOWED_CHANNEL = %w[public private].freeze
      ALLOWED_SORT    = %w[name msgs].freeze
      def channels_list(filter: '', type: 'public', sort_by: 'name', limit: 500)
        argument_is_in(ALLOWED_CHANNEL, type)
        argument_is_in(ALLOWED_SORT, sort_by)

        { msg: 'method',
          method: 'channelsList',
          params: [filter, type, limit, sort_by] }
      end

      #=
      #= * `get_users_of_room`
      #=   * `room_id:`
      #=   * `offline_users:` true/false
      
      def get_users_of_room(room_id:, offline_users: 'false')
        { msg: 'method',
          method: 'getUsersOfRoom',
          params: [room_id, offline_users] }
      end
      
      #= * `read_messages`
      def read_messages
        { msg: 'method',
          method: 'readMessages',
          params: [] }
      end

      private

      def argument_is_in(allowed, arg)
        raise ArgumentNotAllowed, "should be in [#{allowed.join(' ')}]" \
          unless allowed.include? arg
      end

    end
  end
end

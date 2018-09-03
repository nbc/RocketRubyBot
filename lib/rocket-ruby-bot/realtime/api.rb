module RocketRubyBot
  module Realtime
    module API

      class ArgumentError < StandardError; end
      class UnknownArgumentValue < StandardError; end

      KNOWN_STATUS = %W<online busy away offline>.freeze
      CHANNEL_TYPE = %w[public private].freeze
      SORT_TYPE    = %w[name msgs].freeze
      
      def send_login(options)
        if options.has_key? :digest and options.has_key? :username
          return {msg: 'method',
                  method: 'login',
                  params: [{ user: { username: options[:username] },
                             password: { digest: options[:digest], algorithm: "sha-256" }}]}
        elsif options.has_key? :token
          return {msg: "method",
                  method: "login",
                  params: [ { resume: options[:token] }]}
        end
        raise ArgumentError, "should have (digest and username) or token"
      end
      
      def send_text_message(message_id:, room_id:, msg:)
        {msg: 'method',method: 'sendMessage',
         'params': [{message_id: uuid, rid: room_id, msg: msg}]}
      end

      def send_pong
        {msg: 'pong'}
      end
      
      def sub_stream_room_messages(room_id:)
        {msg: "sub", name: "stream-room-messages",
         params: [room_id,false]}
      end
      
      def sub_stream_notify_all
        {msg: "sub", name: "stream-notify-all", params:["event", false]}
      end

      def sub_stream_notify_logged
        {msg: "sub",name: "stream-notify-logged", params:["event", false]}
      end
      
      def set_presence(status:)
        raise UnknownArgumentValue, "should be in [#{KNOWN_STATUS.join(" ")}]" unless KNOWN_STATUS.include? status
        {msg: "method", method: "UserPresence:setDefaultStatus",
         params: [status]}
      end

      # methods found at https://github.com/mathieui/unha2/blob/master/docs/methods.rst
      
      def get_room_id(room:)
        {msg: "method", method: "getRoomIdByNameOrId",params: [room]}
      end

      def get_channels_list(filter: "", type: "public", sort_by: "name", limit: 500)
        raise UnknownArgumentValue, "should be in [#{CHANNEL_TYPE.join(" ")}]" unless CHANNEL_TYPE.include? type
        raise UnknownArgumentValue, "should be in [#{SORT_TYPE.join(" ")}]"   unless SORT_TYPE.include? sort_by

        {msg: "method", method: "channelsList", params: [filter, type, limit, sort_by]}
      end
      
      def get_users_of_room(room_id:, user_status: "true")
        {msg: "method", method: "getUsersOfRoom", params: [room_id, user_status]}
      end

      def read_messages
        {msg: "method", method: "readMessages", params: []}
      end
    end
  end
end

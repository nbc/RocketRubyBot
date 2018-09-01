module RocketRubyBot
  module Realtime
    module API

      class UnknownStatus < StandardError; end
      
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        
        def send_text_message(message_id:, room_id:, msg:)
          {msg: 'method',method: 'sendMessage',
           'params': [{message_id: uuid, rid: room_id, msg: msg}]}
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
          raise UnknownStatus unless %W<online busy away offline>.include? status
          {msg: "method", method: "UserPresence:setDefaultStatus",
           params: [status]}
        end
        
      end
    end
  end
end

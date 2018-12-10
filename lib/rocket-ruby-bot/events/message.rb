module RocketRubyBot
  module Events
    # login class
    class Message < Base
      register :room_message
      attr_writer :routes

      def routes
        @routes ||= RocketRubyBot::Commands.routes || []
      end
      
      def call(client, message)
        return if message_to_self? message

        routes.find do |route|
          match = message.msg.match route[:regexp]
          next unless match
          
          next if send_to_other_bot(client, match)
          
          route[:block].call(client, message, match)
          true
        end
      end

      def send_to_other_bot(client, match)
        match.names.include?('bot') && !client.name?(match[:bot])
      end
      
      def message_to_self?(message)
        config.user_id == message.u._id
      end

      register :message
    end
  end
end

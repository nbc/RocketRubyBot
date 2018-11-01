module RocketRubyBot
  module Events
    # login class
    class Message < Base
      attr_reader :routes

      def initialize(routes: RocketRubyBot::Commands.routes)
        @routes = routes
      end

      # {"msg":"changed","collection":"stream-room-messages","id":"id",
      #  "fields":{"eventName":"WNqBb5jkkFNeYswcp",
      #            "args":[{"_id":"357Cde8axgiCYd3kY","rid":"WNqBb5jkkFNeYswcp","msg":"rbot text here","ts":{"$date":1540756719398},
      #                     "alias":"C Nicolas","u":{"_id":"vNW5eZW5Ma823XNt3","username":"nicolas.c","name":"C Nicolas"},
      #                     "mentions":[],"channels":[],"_updatedAt":{"$date":1540756719402}}]}}

      def call(client, data)
        message = data.fields.args.first
        return if message_to_self?(message)
        
        route = routes.find { |r| message.msg.match r[:regexp] }
        return unless route

        match = message_match_route?(message)
        return unless send_to_bot(match)
        
        route[:block].call(client, message, match) if match
      end

      def send_to_bot(match)
        match.include('bot') && client.name?(match['bot'])
      end
      
      def message_to_self?(message)
        config.user_id == message.u['_id']
      end

      def message_match_route?(message)
        message.msg.match route[:regexp]
      end
    end
  end
end

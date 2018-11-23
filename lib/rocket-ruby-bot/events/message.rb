module RocketRubyBot
  module Events
    # login class
    class Message < Base
      attr_accessor :routes

      def initialize(routes: RocketRubyBot::Commands.routes)
        @routes = routes
      end

      # FIXME
      register :room_message
      
      # sample message :
      # {"msg":"changed","collection":"stream-room-messages","id":"id",
      #  "fields":{"eventName":"WNqBb5jkkFNeYswcp",
      #            "args":[{"_id":"357Cde8axgiCYd3kY",
      #                      "rid":"WNqBb5jkkFNeYswcp",
      #                     "msg":"rbot text here",
      #                     "ts":{"$date":1540756719398},
      #                     "alias":"C Nicolas",
      #                     "u":{"_id":"vNW5eZW5Ma823XNt3",
      #                          "username":"nicolas.c",
      #                          "name":"C Nicolas"},
      #                     "mentions":[],"channels":[],"_updatedAt":{"$date":1540756719402}}]}}

      def call(client, data)
        message = data.fields.args.first
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
        config.user_id == message.u['_id']
      end
    end
  end
end

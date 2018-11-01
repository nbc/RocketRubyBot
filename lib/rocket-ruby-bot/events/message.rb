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

        # never reply to self
        return if config.user_id == message.u['_id']

        route = routes.find { |route| message.msg.match route[:regexp] }
        return unless route
        
        if match = message.msg.match(route[:regexp])
          route[:block].call(client, message, match)
        end

      end
    end
  end
end

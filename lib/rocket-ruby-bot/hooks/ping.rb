module RocketRubyBot
  module Hooks
    class Ping < Base
      def call(client, data)
        client.say send_pong, false
      end

    end
  end
end

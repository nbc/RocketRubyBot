module RocketRubyBot
  module Hooks
    class Ping < Base
      def call(client, data)
        client.say send_pong
      end

    end
  end
end

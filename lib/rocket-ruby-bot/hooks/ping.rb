module RocketRubyBot
  module Hooks
    # respond to server's ping
    class Ping < Base
      def call(client, _data)
        client.send_json send_pong
      end

    end
  end
end

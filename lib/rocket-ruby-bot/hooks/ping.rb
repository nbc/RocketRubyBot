module RocketRubyBot
  module Hooks
    class Ping < RocketRubyBot::Commands
      
      command :ping do |client, data|
        client.say send_pong
      end

    end
  end
end

module RocketRubyBot
  module Hooks
    class Connected < Commands

      command :connected do |client, data|
        client.say send_login(token: config.token) do |message|
          config.user_id = message.result['id']
        end
      end
      
    end
  end
end

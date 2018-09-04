module RocketRubyBot
  module Hooks
    class Connected < Base

      def initialize(config: config)
        @config = config
      end
      
      def call(client, data)
        client.say send_login(token: @config.token) do |message|
          @config.user_id = message.result['id']
        end
      end
      
    end
  end
end

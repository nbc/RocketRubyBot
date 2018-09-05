module RocketRubyBot
  module Hooks
    class Connected < Base

      def initialize(config:)
        @config = config
      end
      
      def call(client, data)
        client.say send_login(token: @config.token) do |message|
          if message.error and message.error.error == 403
            logger.fatal "authentication failed"
            raise "authentication failed"
          end
          @config.user_id = message.result['id']
        end
      end
      
    end
  end
end

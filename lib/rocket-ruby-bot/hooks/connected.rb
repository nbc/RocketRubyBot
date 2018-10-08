module RocketRubyBot
  module Hooks
    class Connected < Base

      def initialize(config:, logger:)
        @config = config
        @logger = logger
      end
      
      def call(client, data)
        client.say login(token: @config.token) do |message|
          if message.error
            @logger.fatal message.error.message
            raise message.error.message
          end
          @config.user_id = message.result['id']
        end
      end
      
    end
  end
end

module RocketRubyBot
  module Events
    # login class
    class Connected < Base
      def call(client, _data)
        client.say login(username: config.user,
                         digest: config.digest,
                         token: config.token) do |message|
          if message.error
            logger.fatal message.error.message
            raise message.error.message
          end
          config.user_id = message.result['id']
          config.token = message.result['token']
        end
      end
    end
  end
end

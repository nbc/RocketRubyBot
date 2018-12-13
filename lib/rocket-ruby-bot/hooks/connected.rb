module RocketRubyBot
  module Hooks
    # login class
    class Connected < Base
      register :connected

      def call(client, _data)
        message = client.login(username: config.user,
                               digest: config.digest,
                               token: config.token)
        pp message
        if not message.token
          logger.fatal message.error
          raise message.error
        end
        config.user_id = message.user_id
        config.token = message.token
      end
    end
  end
end

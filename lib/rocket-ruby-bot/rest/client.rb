require 'rocketchat'

module RocketRubyBot
  module Rest
    module Client

      def self.session(url:, token:, user_id:)
        server = RocketChat::Server.new(url)
        token  = RocketChat::Token.new(authToken: token,
                                       userId: user_id)
        RocketChat::Session.new(server, token)
      end
    end
  end
end

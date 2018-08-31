module RocketRubyBot
  class WebClient < RocketChat::Session
    def initialize
      url = RocketRubyBot::Config.url
      
      rs = RocketChat::Server.new(url)
      token = RocketChat::Token.new(authToken: RocketRubyBot::Config.token,
                                    userId: RocketRubyBot::Config.user_id)
      super(rs, token)
    end
  end
end

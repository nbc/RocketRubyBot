module RocketRubyBot
  class WebClient < RocketChat::Session
    def initialize(url:, token:, user_id:)
      @url     = url
      @token   = token
      @user_id = user_id
      
      rs    = RocketChat::Server.new(url)
      token = RocketChat::Token.new(authToken: token,
                                    userId: user_id)
      super(rs, token)
    end
  end
end

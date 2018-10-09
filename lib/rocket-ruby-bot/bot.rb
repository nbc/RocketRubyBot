module RocketRubyBot
  class Bot < RocketRubyBot::Commands

    include RocketRubyBot::UUID
    include RocketRubyBot::UserStore
    
    def self.run
      RocketRubyBot::App.instance.run(RocketRubyBot.config.websocket_url)
    end

    def self.web_client
      @session ||= RocketRubyBot::Rest::Client.session(url:     RocketRubyBot.config.url,
                                                       token:   RocketRubyBot.config.token,
                                                       user_id: RocketRubyBot.config.user_id)
    end
    
    def self.user_store
      RocketRubyBot::UserStore.user_store
    end


    def web_client
      self.class.web_client
    end

    def user_store
      self.class.user_store
    end
  end
end

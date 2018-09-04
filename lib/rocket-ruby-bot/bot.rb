module RocketRubyBot
  class Bot < RocketRubyBot::Commands

    include RocketRubyBot::UUID
    
    def self.run
      RocketRubyBot::App.instance.run(RocketRubyBot.config.url)
    end

    def self.web_client
      @session ||= RocketRubyBot::Rest::Client.new(url: RocketRubyBot.config.url,
                                                   token: RocketRubyBot.config.token,
                                                   user_id: RocketRubyBot.config.user_id)
    end
    
    def self.store
      RocketRubyBot::Store
    end
    
  end
end

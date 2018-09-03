module RocketRubyBot
  class Bot < RocketRubyBot::Commands

    include RocketRubyBot::UUID
    include RocketRubyBot::Utils
    
    def self.run(url)
      RocketRubyBot::Server.instance.run(url)
    end

    def self.web_client
      RocketRubyBot::Rest::Client.new
    end
    
    def self.store
      RocketRubyBot::Store
    end
    
  end
end

module RocketRubyBot
  class Bot < RocketRubyBot::Commands

    include RocketRubyBot::UUID
    include RocketRubyBot::Utils
    include RocketRubyBot::Realtime::API
    
    def self.run(url)
      instance.run(hooks, url)
    end


    def self.instance
      RocketRubyBot::Client.instance
    end

    def self.config
      RocketRubyBot::Config
    end

    def self.web_client
      RocketRubyBot::WebClient.new
    end
    
    def self.store
      RocketRubyBot::Store
    end
    
  end
end

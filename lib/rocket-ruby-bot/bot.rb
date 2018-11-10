module RocketRubyBot
  class Bot < Commands

    include RocketRubyBot::Utils::UUID
    include RocketRubyBot::UserStore

    def self.run
      RocketRubyBot::Server.instance.run
    end

    def self.web_client
      @web_client ||= RocketRubyBot::Rest::Client.session(
        url:     RocketRubyBot::Config.url,
        token:   RocketRubyBot::Config.token,
        user_id: RocketRubyBot::Config.user_id
      )
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

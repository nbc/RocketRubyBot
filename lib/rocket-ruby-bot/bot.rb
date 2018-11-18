module RocketRubyBot
  class Bot < Commands

    def self.run
      RocketRubyBot::Server.instance.run
    end
  end
end

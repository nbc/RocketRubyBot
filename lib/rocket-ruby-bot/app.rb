module RocketRubyBot
  class App < Server

    def initialize(options = {})
      RocketRubyBot.configure do |config|
        config.token = ENV['ROCKET_API_TOKEN'] || raise("Missing ENV['ROCKET_API_TOKEN'].")
      end
      super
    end

    def self.instance
      @instance ||= new
    end

  end
end

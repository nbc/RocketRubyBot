module RocketRubyBot
  class App < Server

    def initialize(config: RocketRubyBot.config)
      super
    end

    def self.instance
      @instance ||= new
    end

  end
end

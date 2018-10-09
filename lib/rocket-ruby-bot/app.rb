module RocketRubyBot
  class App < Server

    def initialize(options = {})
      super
    end

    def self.instance
      @instance ||= new
    end

  end
end

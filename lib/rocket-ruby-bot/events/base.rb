module RocketRubyBot
  module Events
    # every event should inherit from this class
    class Base
      include RocketRubyBot::Realtime::API
    end
  end
end

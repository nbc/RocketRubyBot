module RocketRubyBot
  module Hooks
    class Base
      include RocketRubyBot::Realtime::API
      include RocketRubyBot::Loggable
    end
  end
end

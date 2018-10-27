module RocketRubyBot
  module Hooks
    # every hooks should inherit from this class
    class Base
      include RocketRubyBot::Realtime::API
    end
  end
end

module RocketRubyBot
  module Hooks
    # every event should inherit from this class
    class Base
      include RocketRubyBot::API::Methods
      include RocketRubyBot::API::Miscs
      include RocketRubyBot::API::Streams
      include RocketRubyBot::Utils::Loggable

      class << self
        attr_accessor :hooks

        def event_hooks
          RocketRubyBot::Hooks::Base.hooks ||= Hash.new { |h, k| h[k] = [] }
        end
        
        def register(hook)
          event_hooks[hook] << self.new
        end
      end

      def config
        RocketRubyBot::Config
      end
    end
  end
end

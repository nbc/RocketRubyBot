# coding: utf-8

module RocketRubyBot
  class Commands
    include RocketRubyBot::Loggable
    extend RocketRubyBot::Realtime::API
    extend RocketRubyBot::Routes
    
    class << self

      def hooks
        RocketRubyBot::Server.instance.hooks
      end

      def config
        RocketRubyBot.config
      end

      def on_event(type, &block)
        hooks[type] << block
      end

      def setup(&block)
        on_event :authenticated do |client, data|
          yield client
        end
      end

      def help
      end
      
    end
  end
end

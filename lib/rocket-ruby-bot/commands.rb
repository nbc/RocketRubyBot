# coding: utf-8

module RocketRubyBot
  class RocketRubyBot::Commands
    include RocketRubyBot::Loggable
    extend RocketRubyBot::Realtime::API
    
    class << self

      def hooks
        RocketRubyBot::App.instance.hooks
      end

      def config
        RocketRubyBot.config
      end
      
      def on_event(type, &block)
        hooks[type] << block
      end

      def on_message(regexp, &block)
        on_event :message do |client, data|
          message = data.fields.args.first

          # never answer to ourself
          next if config.user_id == message.u['_id']

          if match = message.msg.match(regexp)
            yield client, message, match
          end
        end
      end
      
    end
  end
end

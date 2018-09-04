# coding: utf-8
module RocketRubyBot
  class RocketRubyBot::Commands
    include RocketRubyBot::Loggable
    extend RocketRubyBot::Realtime::API
    
    class << self

      def hooks
        RocketRubyBot::App.instance.hooks
      end

      def command(type, &block)
        hooks[type] << block
      end

      def config
        RocketRubyBot.config
      end
      
      def message(regexp, &block)
        command :message do |client, data|
          message = data.fields.args.first

          # on ne se répond pas à soi-même !
          next if config.user_id == message.u['_id']

          match = regexp.match message.msg
          if match
            block.call(client, message, match)
          end
        end
      end
      
    end
  end
end

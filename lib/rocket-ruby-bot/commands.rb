# coding: utf-8
module RocketRubyBot
  class RocketRubyBot::Commands

    class << self

      attr_accessor :instance

      def hooks
        @instance ||= Hash.new { |h,k| h[k] = [] }
      end

      def command(type, &block)
        hooks[type] << block
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
      
      def add_hook(type, &block)
        hooks[type.to_s] << block
      end

    end
  end
end

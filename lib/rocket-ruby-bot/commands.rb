# coding: utf-8

module RocketRubyBot
  class Commands
    include RocketRubyBot::Realtime::API
    include RocketRubyBot::Routes

    include RocketRubyBot::Utils::Loggable
    include RocketRubyBot::Utils::UUID
    include RocketRubyBot::UserStore

    class << self
      def hooks
        RocketRubyBot::Server.instance.hooks
      end

      def config
        RocketRubyBot.config
      end

      def on_event(*types, &block)
        types.each do |type|
          hooks[type] << block
        end
      end

      def setup(&_block)
        on_event :authenticated do |client, _data|
          yield client
        end
      end

      def closing(&_block)
        on_event :closing do |client, _data|
          yield client
        end
      end
      
      def help; end

      def web_client
        @web_client ||= RocketRubyBot::Rest::Client.session(
          url: RocketRubyBot::Config.url,
          token: RocketRubyBot::Config.token,
          user_id: RocketRubyBot::Config.user_id
        )
      end
    
      def user_store
        RocketRubyBot::UserStore.user_store
      end

      def dump(object)
        return object unless object.respond_to? :each_pair

        object.each_pair.with_object({}) do |(key, value), hash|
          hash[key] = case value
          when OpenStruct
            dump(value)
          when Array
            value.map { |a| dump(a) }
          else
            value
          end
        end
      end
    end
  end
end

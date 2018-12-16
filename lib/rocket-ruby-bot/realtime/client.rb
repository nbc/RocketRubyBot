require 'faye/websocket'
require 'eventmachine'
require 'json'
require_relative '../utils/sync'
require 'fiber'

module RocketRubyBot
  module Realtime
    # low level interaction with websocket server
    class Client
      include RocketRubyBot::Utils::Loggable
      include RocketRubyBot::Utils::MessageId
      include RocketRubyBot::Utils::Sync
      
      attr_accessor :hooks
      attr_writer :web_socket
      
      def initialize(hooks, url)
        @hooks = hooks
        @url = url
      end

      def exec_on_close(&block)
        @on_close = block
      end

      def name?(name)
        RocketRubyBot::Config.bot_names.include?(name.downcase)
      end

      def merge_arguments(args)
        uid = next_id
        args = { id: uid }.merge(args)
        logger.debug("-> #{args.to_json}")

        [uid, args]
      end

      def method_missing(method, *params)
        if API::Methods.respond_to? method
          params = API::Methods.send method, *params
          return sync_say params, method
        elsif API::Streams.respond_to? method
          params = API::Streams.send method, *params
          return say params
        end

        super
      end

      def respond_to_missing?(method, include_private = false)
        API::Methods.respond_to?(method) || API::Streams.respond_to?(method) || super
      end
      
      def say(args = {}, &block)
        uid, args = merge_arguments args
        block_fiber(uid, &block) if block_given?
        send_json(args)
      end

      def sync_say(args, method = false)
        uid, args = merge_arguments args
        sync_fiber(uid, method) { send_json(args) }
      end
      
      def send_json(args)
        web_socket.send(args.to_json)
      end
      
      def dispatch_event(data)
        event = RocketRubyBot::Realtime::Events::EventFactory.builder data

        resume_fiber(event.id, event.value) if event.respond_to? :value
        run_hooks(event)
      end

      def run_hooks(data)
        return unless hooks.key? data.type

        hooks[data.type].each do |hook|
          event_fiber { hook.call(self, data) }
        end
      end
      
      # FIXME
      def stop
        hooks[:closing].each do |hook|
          hook.call(self, '')
        end

        web_socket.close
        EM.stop if EM.reactor_running?
      end

      def web_socket
        @web_socket ||= Faye::WebSocket::Client.new(@url)
      end

      def on_open
        logger.debug(':open')
        send_json(API::Miscs.connect)
      end

      def on_message(event)
        logger.debug("<- #{event.data}")
        dispatch_event JSON.parse(event.data)
      end

      def on_close(event)
        logger.debug ":close #{event.code} #{event.reason}"
        @on_close.call(event)
      end

      def start
        EM.run do
          web_socket.on :open do |_event|
            on_open
          end
          web_socket.on :message do |event|
            on_message(event)
          end
          web_socket.on :close do |event|
            on_close(event)
          end
        end
      end
    end
  end
end

require 'faye/websocket'
require 'eventmachine'
require 'json'
require_relative '../utils/sync'

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
        @url   = url
      end

      def exec_on_close(&block)
        @on_close = block
      end

      def names
        [RocketRubyBot::Config.user.downcase]
      end
      
      def name?(name)
        names.include?(name.downcase)
      end
      
      def say(args = {}, &block)
        uid = next_id
        args = { id: uid }.merge(args)

        create_fiber(uid, &block) if block_given?
        send_json(args)
      end

      def send_json(args)
        web_socket.send(args.to_json)
      end
      
      def dispatch_event(data)
        return unless data._type
        logger.debug("<- #{data.to_json}") unless data.ping?
        resume_fiber(data)
        return unless hooks.key? data._type
        hooks[data._type].each do |hook|
          hook.call(self, data)
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
        logger.debug(":open")
        send_json(API.connect)
      end

      def on_message(event)
        data = RocketRubyBot::Realtime::Event.new JSON.parse(event.data)
        dispatch_event(data)
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

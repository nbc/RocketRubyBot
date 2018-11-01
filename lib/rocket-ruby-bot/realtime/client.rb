require 'faye/websocket'
require 'eventmachine'
require 'json'
require_relative '../utils/sync'

module RocketRubyBot
  module Realtime
    # low level interaction with websocket server
    class Client
      include RocketRubyBot::Loggable
      include RocketRubyBot::MessageId
      include RocketRubyBot::Utils::Sync
      
      attr_accessor :hooks
      attr_reader :web_socket
      
      def initialize(hooks, url)
        @hooks = hooks
        @url   = url
      end

      def on_close(&block)
        @on_close = block
      end

      def say(args = {}, &block)
        uid = next_id
        args = { id: uid }.merge(args)

        logger.debug("-> #{args.to_json}") unless args[:msg] == 'pong'
       
        if block_given?
          create_fiber(uid, &block)
        end

        web_socket.send(args.to_json)
      end

      def dispatch_event(data)
        return unless data._type
        
        # no log for ping
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
        EM.stop
      end

      def start
        @hooks = hooks

        EM.run do
          @web_socket = Faye::WebSocket::Client.new(@url)

          web_socket.on :open do |_event|
            p [:open]
            web_socket.send({ 'msg' => 'connect',
                               'version' => '1',
                               'support' => ['1'] }.to_json)
          end

          web_socket.on :message do |event|
            data = RocketRubyBot::Realtime::Event.new JSON.parse(event.data)
            dispatch_event(data)
          end

          web_socket.on :close do |event|
            p [:close]
            @on_close.call(event)
          end
        end
      end
    end
  end
end

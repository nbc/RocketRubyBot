require 'faye/websocket'
require 'eventmachine'
require 'json'

module RocketRubyBot
  module Realtime
    # low level interaction with websocket server
    class Client
      include RocketRubyBot::Loggable
      include RocketRubyBot::MessageId

      attr_accessor :hooks
      attr_reader :web_socket
      
      def self.fiber_store
        @fiber_store ||= {}
      end

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
          f = Fiber.new do
            message = Fiber.yield
            yield message
          end
          Client.fiber_store[uid] = f
          f.resume
        end

        web_socket.send(args.to_json)
      end

      def dispatch_event(data)
        return unless data._type
        
        # no log for ping
        logger.debug("<- #{data.to_json}") unless data.ping?

        if Client.fiber_store.key? data.result_id
          Client.fiber_store[data.result_id].resume data
          Client.fiber_store.delete data.result_id
        end

        type = data._type

        return unless @hooks.key? type

        hooks[type].each do |hook|
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

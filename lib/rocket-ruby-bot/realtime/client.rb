require 'faye/websocket'
require 'eventmachine'
require 'json'

module RocketRubyBot
  module Realtime
    class Client
      include RocketRubyBot::Loggable
    
      class NoValidURL < StandardError; end
      
      include RocketRubyBot::MessageId
      
      attr_accessor :hooks

      # FIXME
      @@fiber_store = Hash.new

      def self.instance
        @instance ||= new
      end
      
      def initialize(hooks, url)
        @hooks = hooks

        @url = url.gsub 'https://', 'wss://'
        @url.gsub! %r{/$}, ''
        @url.concat '/websocket'

        raise NoValidURL unless %r{wss?://}.match(@url)
      end

      def on_close(&block)
        @on_close = block
      end
      
      def say(args = {}, id = true, &block)

        if id
          uid = next_id
          args = {id: uid}.merge(args)
          # no log for ping
          logger.debug("-> #{args}")
        end

        if block_given?
          f = Fiber.new do
            @web_socket.send(args.to_json)
            message = Fiber.yield
            block.call message
          end
          @@fiber_store[uid] = f
          f.resume
        else
          @web_socket.send(args.to_json)
        end
      end

      def dispatch_event(data)
        return unless data._type

        # no log for ping
        logger.debug("<- #{data.to_json}") unless data.is_ping?

        if @@fiber_store.has_key? data.uid
          @@fiber_store[data.uid].resume data
          @@fiber_store.delete data.uid
        end

        type = data._type
        return unless @hooks[type]

        hooks[type].each do |hook|
          hook.call(self, data)
        end
      end

      # FIXME
      def stop
        hooks[:closing].each do |hook|
          hook.call(self, '')
        end
        
        @web_socket.close
        EM.stop
      end
      
      def start
        @hooks = hooks
        
        EM.run do
          @web_socket = Faye::WebSocket::Client.new(@url)
          
          @web_socket.on :open do |event|
            p [:open]
            @web_socket.send({"msg" => "connect", "version" => "1", "support" =>  ["1"]}.to_json)
          end

          @web_socket.on :message do |event|
            data = RocketRubyBot::Realtime::Event.new JSON.parse(event.data)
            dispatch_event(data)
          end

          @web_socket.on :close do |event|
            p [:close]
            @on_close.call(event)
          end
        end
      end
    end
  end
end

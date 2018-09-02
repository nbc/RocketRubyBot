module RocketRubyBot
  module Realtime
    class Client
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
          id = next_id
          args = {id: id}.merge(args)
        end

        p [ "-> ", args]
        if !block_given?
          @web_socket.send(args.to_json)
        else
          f = Fiber.new do
            @web_socket.send(args.to_json)
            message = Fiber.yield
            block.call message
          end
          @@fiber_store[id] = f
          f.resume
        end
      end

      def dispatch_messages(data)
        return unless data._type
        type = data._type

        if @@fiber_store.has_key? data.uid
          @@fiber_store[data.uid].resume data
          @@fiber_store.delete data.uid
        end

        return unless @hooks[type]
        hooks[type].each do |hook|
          hook.call(self, data)
        end
      end

      def stop
        @web_socket.close
        EM.stop
      end
      
      def start
        @hooks = hooks
        # FIXME no httpS
        
        EM.run do
          @web_socket = Faye::WebSocket::Client.new(@url)
          
          @web_socket.on :open do |event|
            p [:open]
            @web_socket.send({"msg" => "connect", "version" => "1", "support" =>  ["1"]}.to_json)
          end

          @web_socket.on :message do |event|
            p ["<- ", JSON.parse(event.data)]

            data = RocketRubyBot::Message.new JSON.parse(event.data)
            dispatch_messages(data)
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

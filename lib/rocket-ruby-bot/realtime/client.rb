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
      
      def initialize
        @url = nil
        @web_socket = nil
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

      def run(hooks, url)
        @hooks = hooks
        # FIXME no httpS
        @url = url.gsub 'https://', 'wss://'
        @url.gsub! %r{/$}, ''
        @url.concat '/websocket'

        raise NoValidURL unless %r{wss?://}.match(@url)
        
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
            p [:close, event.code, event.reason]
            @web_socket = nil
            EM.stop
          end

        end
      end
    end
  end
end

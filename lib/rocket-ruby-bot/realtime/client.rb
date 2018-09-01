module RocketRubyBot
  module Realtime
    class Client

      class NoValidURL < StandardError; end
      
      include RocketRubyBot::MessageId
      
      attr_accessor :hooks

      def self.instance
        @instance ||= new
      end
      
      def initialize
        @url = nil
        @web_socket = nil
      end

      def say(args = {})
        id = next_id
        args = {id: id}.merge(args)
        p [ "-> ", args]
        @web_socket.send(args.to_json)
      end

      def dispatch_messages(data)
        p ["<- ", data]
        return unless data._type
        type = data._type
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
            say({"msg" => "connect", "version" => "1", "support" =>  ["1"]})
          end

          @web_socket.on :message do |event|
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

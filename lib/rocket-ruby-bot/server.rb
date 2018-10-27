require 'forwardable'
require 'singleton'

module RocketRubyBot
  class Server
    include Loggable
    
    attr_accessor :hooks, :websocket_url
    
    TRAPPED_SIGNALS = %w[INT TERM].freeze

    def initialize(config:, options: {})
      @hooks = Hash.new { |h, k| h[k] = [] }

      @websocket_url = config.websocket_url
      
      if options.empty?
        @hooks.merge!(connected: [RocketRubyBot::Hooks::Connected.new(config: config,
                                                                      logger: logger)],
                      ping: [RocketRubyBot::Hooks::Ping.new])
      else
        @hooks.merge! options
      end
    end

    def run
      loop do
        handle_signals
        start!
      end
    end

    def start!
      @stopping = false
      client.start
    end

    def stop!
      @stopping = true
      client.stop if client
    end

    def restart!
      start! 
    rescue StandardError => e
      logger.error "#{RocketRubyBot.config.token}: #{e.message}"
      @stopping = true
    end
    
    def handle_signals
      TRAPPED_SIGNALS.each do |signal|
        Signal.trap(signal) do
          stop!
          exit
        end
      end
    end

    def client(client: nil)
      @client ||= client || begin
        cl = RocketRubyBot::Realtime::Client.new(hooks, websocket_url)
        cl.on_close do |_data|
          @client = nil
          restart! unless @stopping
        end
        
        cl
      end
      
    end
  end
end

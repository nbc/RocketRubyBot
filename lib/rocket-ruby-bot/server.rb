require 'forwardable'

module RocketRubyBot
  class Server
    include RocketRubyBot::Utils::Loggable
    
    attr_accessor :websocket_url
    attr_writer :hooks
    
    TRAPPED_SIGNALS = %w[INT TERM].freeze

    def initialize(config:)
      @websocket_url = config.websocket_url
    end

    def hooks
      # FIXME: why dup ?
      @hooks ||= RocketRubyBot::Events::Base.event_hooks.dup
    end

    def self.instance
      @instance ||= new(config: RocketRubyBot.config)
    end
    
    def run
      loop do
        trap_signals
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
    
    def trap_signals
      TRAPPED_SIGNALS.each do |signal|
        Signal.trap(signal) do
          signal_handler
        end
      end
    end

    def signal_handler
      stop!
      exit
    end
    
    def client(client: nil)
      @client ||= client || begin
        cl = RocketRubyBot::Realtime::Client.new(hooks, websocket_url)
        cl.exec_on_close do |_data|
          @client = nil
          restart! unless @stopping
        end
        
        cl
      end
      
    end
  end
end

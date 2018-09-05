require 'forwardable'
require 'singleton'

module RocketRubyBot
  class Server
    include Loggable
    
    attr_accessor :hooks, :url
    
    TRAPPED_SIGNALS = %w[INT TERM].freeze

    def initialize(options = {})
      @hooks = Hash.new { |h,k| h[k] = [] }
      @hooks[:connected].push RocketRubyBot::Hooks::Connected.new(config: RocketRubyBot.config,
                                                                  logger: logger)
      @hooks[:ping].push RocketRubyBot::Hooks::Ping.new
    end

    def run(url)
      @url = url

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

    def handle_signals
      TRAPPED_SIGNALS.each do |signal|
        Signal.trap(signal) do
          stop!
          exit
        end
      end
    end

    def client
      @client ||= begin
        client = RocketRubyBot::Realtime::Client.new(hooks, url)
        client.on_close do |_data|
          @client = nil
          # restart! unless @stopping
        end
        
        client
      end
      
    end
  end
end

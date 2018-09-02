require 'forwardable'
require 'singleton'

module RocketRubyBot
  class Server
    include Singleton
    
    TRAPPED_SIGNALS = %w[INT TERM].freeze

    def initialize(options = {})
      RocketRubyBot.configure do |config|
        config.token = ENV['ROCKET_API_TOKEN'] || raise("Missing ENV['ROCKET_API_TOKEN'].")
      end
    end

    def run(hooks, url)
      @hooks = hooks
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
      client.stop if @client
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
        client = RocketRubyBot::Realtime::Client.new(@hooks, @url)
        client.on_close do |_data|
          @client = nil
          # restart! unless @stopping
        end
        
        client
      end
      
    end
  end
end

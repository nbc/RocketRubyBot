require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'rocketchat'
require 'hashie'

require 'rocket-ruby-bot/utils'
require 'rocket-ruby-bot/message'
require 'rocket-ruby-bot/realtime/api'
require 'rocket-ruby-bot/config'
require 'rocket-ruby-bot/rest/client'
require 'rocket-ruby-bot/realtime/client'    
require 'rocket-ruby-bot/server'
require 'rocket-ruby-bot/commands'
require 'rocket-ruby-bot/bot'

module RocketRubyBot
  class << self
    def configure
      block_given? ? yield(Config) : Config
    end

    def config
      Config
    end
  end
end

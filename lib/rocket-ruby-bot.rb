require 'rocket-ruby-bot/version'
require 'rocket-ruby-bot/utils'
require 'rocket-ruby-bot/api'
require 'rocket-ruby-bot/config'
require 'rocket-ruby-bot/user_store'
require 'rocket-ruby-bot/events'

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

require 'rocket-ruby-bot/routes'
require 'rocket-ruby-bot/commands'
require 'rocket-ruby-bot/rest/client'
require 'rocket-ruby-bot/realtime/client'    
require 'rocket-ruby-bot/server'
require 'rocket-ruby-bot/hooks'
require 'rocket-ruby-bot/bot'

require 'rocket-ruby-bot/api/methods'
require 'rocket-ruby-bot/api/streams'
require 'rocket-ruby-bot/api/miscs'

module RocketRubyBot
  module API
    def self.class_for(method)
      [API::Methods, API::Streams].find { |klass| klass.respond_to? method }
    end
  end
end

require 'rocket-ruby-bot/api/methods'
require 'rocket-ruby-bot/api/streams'
require 'rocket-ruby-bot/api/miscs'

module RocketRubyBot
  module API
    def self.class_for(method)
      [Methods, Streams].find { |klass| klass.respond_to? method }
    end

    def self.has_method?(method)
      class_for(method) and true
    end
    
    def self.params_for(method, *params)
      klass = class_for method
      return unless klass
      
      klass.send method, *params
    end
  end
end

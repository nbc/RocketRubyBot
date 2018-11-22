require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      BASIC_EVENTS = %w[ping connected ready updated removed
                        failed error nosub added].freeze

      @basic_events = {}
      def self.basic_events
        @basic_events
      end
      
      BASIC_EVENTS.each do |event|
        klass = self.const_set event.capitalize, Class.new(::OpenStruct)
        @basic_events[event] = klass
        klass.define_method :type do
          event.to_sym
        end
      end
      
      class Result < ::OpenStruct
        def token?
          return true if self.result.respond_to?(:token)
        end

        def type
          return :authenticated if token?
          :result
        end
      end
      @basic_events['result'] = Result
    end
  end
end

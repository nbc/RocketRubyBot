require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      BASIC_EVENTS = %w[ping connected ready updated removed
                        failed error nosub added result].freeze
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
    end
  end
end

require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      BASIC_EVENTS = %w[ping connected ready updated removed
                        failed error nosub added result].freeze

      # FIXME : awful hack to register Result
      @basic_events = {}
      def self.basic_events
        @basic_events
      end
      
      BASIC_EVENTS.each do |event|
        klass = const_set event.capitalize, Class.new(::OpenStruct)
        @basic_events[event] = klass
        klass.send :define_method, :type do
          event.to_sym
        end
      end

      class Ready
        def result_id
          subs.first
        end
      end

      class Result
        def token?
          return true if result.respond_to?(:token)
        end

        def error?
          return true if respond_to?(:error)
        end
        
        def type
          return :authenticated if token?

          :result
        end

        def result_id
          id
        end
      end
    end
  end
end

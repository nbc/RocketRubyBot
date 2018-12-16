require 'ostruct'

module RocketRubyBot
  module Events
    BASIC_EVENTS = %w[ping connected ready updated removed
                        failed error nosub added].freeze

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
      def id
        subs.first
      end
    end
  end
end


module RocketRubyBot
  module Events
    # every event should inherit from this class
    class Base
      include RocketRubyBot::Realtime::API
      include RocketRubyBot::Utils::Loggable

      class << self
        attr_accessor :class_events
        
        def inherited(subclass)
          RocketRubyBot::Events::Base.class_events ||= [] 
          RocketRubyBot::Events::Base.class_events << subclass
        end

        def event_hooks
          hooks = Hash.new { |h, k| h[k] = [] }
          RocketRubyBot::Events::Base.class_events.each do |klass|
            hooks[event_sym(klass)] << klass.new
          end
          hooks
        end

        def event_sym(klass)
          klass.to_s.split(':').last.downcase.to_sym
        end
      end

      def config
        RocketRubyBot::Config
      end
      
    end
  end
end

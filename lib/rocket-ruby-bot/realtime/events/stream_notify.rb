module RocketRubyBot
  module Realtime
    module Events
      module SimpleEventName
        def type
          @type ||= fields.eventName.to_sym
        end
      end

      StreamNotifyLogged = Class.new(OpenStruct).include SimpleEventName
      StreamNotifyAll = Class.new(OpenStruct).include SimpleEventName

      module ComplexEventName
        def type
          @type ||= fields.eventName.split('/')[-1].tr('-', '_').to_sym
        end
      end      

      StreamNotifyUser = Class.new(OpenStruct).include ComplexEventName
      StreamNotifyRoom = Class.new(OpenStruct).include ComplexEventName

      class Unknown < OpenStruct
        include RocketRubyBot::Utils::Loggable

        def initialize(args)
          logger.info [:unknown, args.to_h]
          super args
        end
        
        def type
          @type = :unknown
        end
      end
    end
  end
end

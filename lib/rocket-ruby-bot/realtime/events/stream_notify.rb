module RocketRubyBot
  module Realtime
    module Events
      class StreamNotifyLogged < OpenStruct
        def type
          @type ||= self.fields.eventName.to_sym
        end
      end

      class StreamNotifyAll < OpenStruct
        def type
          @type ||= self.fields.eventName.to_sym
        end
      end

      class StreamNotifyUser < OpenStruct
        def type
          @type ||= self.fields.eventName.split('/')[-1].tr('-','_').to_sym
        end
      end

      class StreamNotifyRoom < OpenStruct
        def type
          @type ||= self.fields.eventName.split('/')[-1].tr('-','_').to_sym
        end
      end

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

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
    end
  end
end

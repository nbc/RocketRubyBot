module RocketRubyBot
  module Realtime
    module Events
      module EventName
        include Utils
        def type
          @type ||= extract_type fields.eventName
        end
      end

      StreamNotifyLogged = Class.new(OpenStruct).include EventName
      StreamNotifyAll = Class.new(OpenStruct).include EventName
      StreamNotifyUser = Class.new(OpenStruct).include EventName
      StreamNotifyRoom = Class.new(OpenStruct).include EventName

      class StreamNotifyUser
        def added_to_group?
          return unless fields.args &&
                        fields.args[0] &&
                        fields.args.first.eql?('inserted')
          
          fields.args[1][:rid]
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

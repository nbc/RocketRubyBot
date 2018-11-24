module RocketRubyBot
  module Realtime
    module Events
      StreamNotifyLogged = Class.new(OpenStruct).include EventName
      StreamNotifyAll = Class.new(OpenStruct).include EventName
      StreamNotifyUser = Class.new(OpenStruct).include EventName
      StreamNotifyRoom = Class.new(OpenStruct).include EventName

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

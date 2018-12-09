module RocketRubyBot
  module Realtime
    module Events
      class StreamNotifyUser
        include Utils

        class StreamNotifyGeneric < OpenStruct
          include Utils
          def type
            @type ||= class_to_snake_case
          end
        end
        
        Notification = Class.new StreamNotifyGeneric
        Message = Class.new StreamNotifyGeneric
        Otr = Class.new StreamNotifyGeneric
        Webrtc = Class.new StreamNotifyGeneric
        
        class RoomsChanged < StreamNotifyGeneric
          # def initialize
          #   super args
          #   fields.args.last._updatedAt = ts_to_datetime fields.args.last._updatedAt
          #   fields.args.last.lastMessage.ts = ts_to_datetime fields.args.last.lastMessage.ts
          #   fields.args.last.lastMessage._updatedAt = ts_to_datetime fields.args.last.lastMessage._updatedAt
          # end
        end

        class SubscriptionsChanged < StreamNotifyGeneric
          # def initialize
          #   fields.args.last.ts = ts_to_datetime fields.args.last.ts
          # end
        end

        STREAM_NOTIFY_USER = {
          'message' => Message,
          'otr' => Otr,
          'webrtc' => Webrtc,
          'notification' => Notification,
          'rooms_changed' => RoomsChanged,
          'subscriptions_changed' => SubscriptionsChanged
        }.freeze
          
        attr_reader :fields
        
        def initialize(params)
          @msg = params.msg
          @collection = params.collection
          @fields = OpenStruct.new eventName: extract_type(params.fields.eventName),
                                   args: []

          if STREAM_NOTIFY_USER.key? @fields.eventName
            build_args(params.fields.args)
          else
            logger.info [:unknown, @fields.eventName]
          end
        end

        def build_args(args)
          if args.first.is_a? String
            @fields.args << args.first
            @fields.args << STREAM_NOTIFY_USER[@fields.eventName].new(args.last)
          else
            @fields.args << STREAM_NOTIFY_USER[@fields.eventName].new(args.first)
          end
        end
        
        def added_to_group
          return unless fields.args &&
                        fields.args.first &&
                        fields.args.first.eql?('inserted')
          
          fields.args[1][:rid]
        end

        def type
          fields.args.last.type
        end
      end
    end
  end
end

module RocketRubyBot
  module Events
    class StreamNotifyGeneric
      include Utils
      def type
        @type ||= class_to_snake_case
      end
    end
    
    class UserNotification < StreamNotifyGeneric
      def initialize(params)
        params = params.first

        @msg = params.text
        @id = params.payload._id
        @rid = params.payload.rid
        @sender = User.new params.payload.sender
        @room_type = params.payload.type
      end
    end

    class UserRoomsChanged < StreamNotifyGeneric
      def initialize(params)
        @keyword = params.first
        @id = params.last._id
        @room_name = params.last.name
        @room_type = params.last.type
        @user = User.new params.last.u
        @last_message = params.last.lastMessage
      end

      #   fields.args.last._updatedAt = ts_to_datetime fields.args.last._updatedAt
      #   fields.args.last.lastMessage.ts = ts_to_datetime fields.args.last.lastMessage.ts
      #   fields.args.last.lastMessage._updatedAt = ts_to_datetime fields.args.last.lastMessage._updatedAt
    end

    class UserSubscriptionsChanged < StreamNotifyGeneric
      def initialize(params)
        @keyword = params.first
        @id = params.last._id
        @user = User.new params.last.u
        @ts = ts_to_datetime(params.last.ts)
        @updated_at = ts_to_datetime(params.last._updatedAt)
        @room_type = params.last.t
        @room_name = params.last.name
        @room_id = params.last.rid
      end

      def added_to_group
        return @room_id if @keyword.eql? 'inserted'
      end
      
      # def initialize
      #   fields.args.last.ts = ts_to_datetime fields.args.last.ts
      # end
    end

    module StreamNotifyUser
      include Utils
      
      STREAM_NOTIFY_USER = {
        'notification' => UserNotification,
        'rooms_changed' => UserRoomsChanged,
        'subscriptions_changed' => UserSubscriptionsChanged
      }.freeze
      
      def self.build(params)
        event_name = Utils.extract_type params.fields.eventName

        if STREAM_NOTIFY_USER.key? event_name
          STREAM_NOTIFY_USER[event_name].new(params.fields.args)
        else
          RocketRubyBot::Realtime::Events::Unknown.new params
        end
      end
    end
  end
end

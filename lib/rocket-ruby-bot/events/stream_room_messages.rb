module RocketRubyBot
  module Events
    class User < ::OpenStruct; end
    


    class RoomEvent
      include Utils

      attr_reader :rid, :_id, :ts, :msg, :u, :_updatedAt, :groupable
      def initialize(params)
        @rid = params.rid
        @_id = params._id
        @ts = ts_to_datetime(params.ts)
        @msg = params.msg
        @u = User.new params.u
        @_updatedAt = ts_to_datetime(params._updatedAt)
      end
      alias_method :room_id, :rid
      alias_method :event_id, :_id
      alias_method :timestamp, :ts
      alias_method :user, :u
    end

    RoomJoin = Class.new(RoomEvent)
    RoomLeft = Class.new(RoomEvent)

    RoomUnmuted = Class.new(RoomEvent).include(UserActor)
    RoomMuted = Class.new(RoomEvent).include(UserActor)
    RoomAdded = Class.new(RoomEvent).include(UserActor)
    RoomRemoved = Class.new(RoomEvent).include(UserActor)

    class RoomRole < RoomEvent
      include UserActor
      attr_reader :role
      def initialize(params)
        super
        @role = params.role
      end
    end

    class RoomRoleAdded < RoomRole; end
    class RoomRoleRemoved < RoomRole; end

    class RoomTopicChanged < RoomEvent
      attr_reader :topic
      def initialize(params)
        super params
        @topic = params.topic
      end
    end

    class RoomMessage < RoomEvent
      attr_reader :urls, :mentions, :editedAt, :editedBy, :alias,
                  :file, :attachments, :reactions
      def initialize(params)
        super params
        @urls = params.urls
        @mentions = (params.mentions || []).map { |u| User.new u }
        @editedAt = ts_to_datetime(params.editedAt)
        @editedBy = params.editedBy || ''
        @alias = params.alias || ''
        @file = params.file if params.file
        @attachments = params.attachments || []
        @reactions = params.reactions
      end
    end

    STREAM_ROOM_MESSAGES =
      { 'uj' => RoomJoin,
        'ul' => RoomLeft,
        'au' => RoomAdded,
        'ru' => RoomRemoved,
        'user-muted' => RoomMuted,
        'user-unmuted' => RoomUnmuted,
        'subscription-role-added' => RoomRoleAdded,
        'subscription-role-removed' => RoomRoleRemoved,
        'room_changed_topic' => RoomTopicChanged }.freeze


    module StreamRoomMessages
      def self.build(params)
        t = params.fields.args.first.t || :message
        if STREAM_ROOM_MESSAGES.key? t
          STREAM_ROOM_MESSAGES[t].new params.fields.args.first
        elsif t == :message
          RoomMessage.new params.fields.args.first
        else
          Unknown.new params
        end
      end
    end
  end
end

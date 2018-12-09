module RocketRubyBot
  module Realtime
    module Events
      class User < ::OpenStruct; end

      class RoomEvent
        include Utils
        attr_reader :rid, :_id, :ts, :msg, :u, :_updatedAt, :groupable
        def initialize(params)
          # @_base = params
          @rid = params.rid
          @_id = params._id
          @ts = ts_to_datetime(params.ts)
          @msg = params.msg
          @u = User.new params.u
          @_updatedAt = ts_to_datetime(params._updatedAt)
          @groupable = params.groupable || false
        end
        alias_method :room_id, :rid
        alias_method :event_id, :_id
        alias_method :timestamp, :ts
        alias_method :user, :u

        def type
          @type ||= class_to_snake_case
        end
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
          super params
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


      class StreamRoomMessages
        attr_reader :msg, :collection, :fields, :id

        def initialize(params)
          @msg = params.msg
          @collection = params.collection
          @id = params.id
          @fields = OpenStruct.new eventName: params.fields.eventName

          t = params.fields.args.first.t || :message
          if STREAM_ROOM_MESSAGES.key? t
            @fields.args = params.fields.args.map { |m| STREAM_ROOM_MESSAGES[t].new m }
          elsif t == :message
            @fields.args = params.fields.args.map { |m| RoomMessage.new m }
          else
            logger.info [:unknown, params.fields.params.first]
          end
        end

        def room_event
          fields.args.first
        end

        def type
          fields.args.first.type
        end
      end
    end
  end
end

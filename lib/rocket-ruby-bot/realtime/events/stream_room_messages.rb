module RocketRubyBot
  module Realtime
    module Events
      class RoomEvent
        include Utils
        attr_reader :rid, :_id, :ts, :msg, :u, :_updatedAt, :groupable
        def initialize(params)
          # @_base = params
          @rid = params.rid
          @_id = params._id
          @ts = params.ts
          @msg = params.msg
          @u = User.new params.u
          @_updatedAt = params._updatedAt
          @groupable = params.groupable
        end
        alias_method :room_id, :rid
        alias_method :event_id, :_id
        alias_method :timestamp, :ts

        def type
          @name ||= to_snake_case
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
        attr_reader :urls, :mentions, :channels, :attachments, :reactions
        def initialize(params)
          super params
          @urls = params.urls
          @mentions = params.mentions.map { |u| User.new u }
          @channels = params.channels
          @editedAt = params.editedAt || ''
          @editedBy = params.editedBy || ''
          @alias = params.alias || ''
          @avatar = params.avatar || ''
          @attachments = params.attachments.map { |a| MessageAttachment.new a }
          @reactions = params.reactions
        end
        alias_method :user, :u
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
        attr_reader :msg, :collection, :fields

        def initialize(params)
          # @_base = params
          @msg = params.msg
          @collection = params.collection

          type = params.fields.params.first.t || :message
          @fields = OpenStruct.new
          @fields.eventName = params.fields.eventName
          if STREAM_ROOM_MESSAGES.key? type
            @fields.params = STREAM_ROOM_MESSAGES[type].new params.fields.params.first
          elsif type == :message
            @fields.params = RoomMessage.new params.fields.params.first
          else
            puts "ERREUR #{params.fields.params.first}"
          end
        end
      end
    end
  end
end

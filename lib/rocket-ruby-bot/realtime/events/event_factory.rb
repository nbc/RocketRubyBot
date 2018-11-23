require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      module EventFactory

        def self.builder(event)
          result = JSON.parse(event, object_class: OpenStruct)
          
          # if BASIC_EVENTS.include? result.msg
          if RocketRubyBot::Realtime::Events.basic_events.key? result.msg
            return RocketRubyBot::Realtime::Events.basic_events[result.msg].new result
          end
          return stream_builder(result) if result.msg.eql? 'changed'

          RocketRubyBot::Realtime::Events::Unknown.new result
        end

        STREAM = { 'stream-room-messages' => StreamRoomMessages,
                   'stream-notify-logged' => StreamNotifyLogged,
                   'stream-notify-user' => StreamNotifyUser,
                   'stream-notify-room' => StreamNotifyRoom }.freeze
        
        def self.stream_builder(event)
          if STREAM.include? event.collection
            STREAM[event.collection].new event
          else
            RocketRubyBot::Realtime::Events::Unknown.new result
          end
        end
      end
    end
  end
end

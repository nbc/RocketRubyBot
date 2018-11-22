require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      module EventFactory
        def self.builder(event)
          result = JSON.parse(event, symbolize_names: true)
          
          if BASIC_EVENTS.include? result[:msg]
            return RocketRubyBot::Realtime::Events.basic_events[result[:msg]].new result
          end

          case result[:msg]
          when 'changed'
            return stream_builder result
          end
        end

        STREAM = { 'stream-room-messages' => StreamRoomMessages,
                   'stream-notify-logged' => StreamNotifyLogged,
                   'stream-notify-user'   => StreamNotifyUser }.freeze
        
        def self.stream_builder(event)
          pp event
          if STREAM.include? event[:collection]
            STREAM[event[:collection]].new event
          end
        end
      end
    end
  end
end

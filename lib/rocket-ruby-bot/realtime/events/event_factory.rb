require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      module EventFactory
        include RocketRubyBot::Utils::Sync
        
        def self.builder(event)
          result = event

          if result.is_a? Hash
            result = JSON.parse(result.to_json, object_class: OpenStruct)
          end

          if result.msg.eql? 'result'
            result_builder(result) 
          elsif result.msg.eql? 'changed'
            stream_builder(result) 
          elsif Events.basic_events.key? result.msg
            basic_event_builder(result)
          else
            Unknown.new result
          end
        end

        def self.basic_event_builder(result)
           Events.basic_events[result.msg].new result
        end
        
        def self.result_builder(result)
          method = RocketRubyBot::Utils::Sync.parse_method(result.id)
          pp method
          if ParseResult.methods.include? method
            ParseResult.send method, result
          else
            Result.new id: result.id, value: result.result
          end
        end

        STREAM = { 'stream-room-messages' => StreamRoomMessages,
                   'stream-notify-logged' => StreamNotifyLogged,
                   'stream-notify-all' => StreamNotifyAll,
                   'stream-notify-user' => StreamNotifyUser,
                   'stream-notify-room' => StreamNotifyRoom }.freeze

        def self.stream_builder(event)
          if STREAM.include? event.collection
            stream = STREAM[event.collection]
            if stream.respond_to? :new
              STREAM[event.collection].new event
            else
              STREAM[event.collection].build event
            end
          else
            RocketRubyBot::Realtime::Events::Unknown.new result
          end
        end
      end
    end
  end
end

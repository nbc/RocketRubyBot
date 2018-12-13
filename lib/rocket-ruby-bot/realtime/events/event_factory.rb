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
          
          return result_builder(result) if result.msg.eql? 'result'
          
          # if BASIC_EVENTS.include? result.msg
          if Events.basic_events.key? result.msg
            return Events.basic_events[result.msg].new result
          end
          return stream_builder(result) if result.msg.eql? 'changed'

          Unknown.new result
        end

        STREAM = { 'stream-room-messages' => StreamRoomMessages,
                   'stream-notify-logged' => StreamNotifyLogged,
                   'stream-notify-all' => StreamNotifyAll,
                   'stream-notify-user' => StreamNotifyUser,
                   'stream-notify-room' => StreamNotifyRoom }.freeze

        def self.result_builder(result)
          method = RocketRubyBot::Utils::Sync.parse_method(result.id)

          if ParseResult.methods.include? method
            ParseResult.send method, result
          else
            Result.new id: result.id, value: result.result
          end
        end
        
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

module RocketRubyBot
  module Realtime
    module Events
      module Utils
        def class_to_snake_case
          name = self.class.name
          name = name.split('::')[-1]
          name.gsub!(/(.)([A-Z])/, '\1_\2')
          name.downcase!
        end

        def to_timestamp(struct)
          return unless struct

          Time.at struct.delete_field('$date') / 1000
        end

        def extract_type(name)
          name.split('/')[-1].tr('-', '_').to_sym
        end

      end

      module EventName
        include Utils
        def type
          @type ||= extract_type fields.eventName
        end
      end

      module UserActor
        def self.included(klass)
          klass.instance_eval do
            alias_method :actor, :u
            alias_method :user, :msg
          end
        end
      end
    end
  end
end


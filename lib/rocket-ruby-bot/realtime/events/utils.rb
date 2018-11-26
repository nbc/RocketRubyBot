module RocketRubyBot
  module Realtime
    module Events
      module Utils
        def class_to_snake_case
          name = self.class.name
          name = name.split('::')[-1]
          to_snake_case(name)
        end

        def to_snake_case(name)
          name.gsub!(/(.)([A-Z])/, '\1_\2')
          name.downcase!
        end
        
        def ts_to_datetime(struct)
          return unless struct

          Time.at struct.delete_field('$date') / 1000
        end

        def extract_type(name)
          name.split('/')[-1].tr('-', '_').to_sym
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


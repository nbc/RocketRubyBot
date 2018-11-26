module RocketRubyBot
  module Realtime
    module Events
      module Utils
        def class_to_snake_case
          name = self.class.name
          to_snake_case name.split('::')[-1]
        end

        def to_snake_case(name)
          name.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            tr(':', '_').
            downcase
        end
        
        def ts_to_datetime(struct)
          return unless struct

          Time.at struct.delete_field('$date') / 1000
        end

        def extract_type(name)
          name = name.split('/')[-1].tr('-', '_')
          to_snake_case(name).to_sym
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


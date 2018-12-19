module RocketRubyBot
  module Events

    class User < ::OpenStruct; end
    
    module Utils
      def type
        @type ||= class_to_snake_case
      end

      extend self
      
      def class_to_snake_case
        extract_type(self.class.name).to_sym
      end

      def extract_type(name)
        name = name.split(%r{::|/})[-1]
        to_snake_case(name)
      end

      def to_snake_case(name)
        name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-:', '_')
          .downcase
      end
      
      def ts_to_datetime(struct)
        return unless struct

        Time.at struct.delete_field('$date') / 1000
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

    class Message
    end

    
  end
end

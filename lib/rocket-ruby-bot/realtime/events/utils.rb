module RocketRubyBot
  module Realtime
    module Events
      module Utils
        def to_snake_case
          name = self.class.name
          name = name.split('::')[-1]
          name.gsub!(/(.)([A-Z])/,'\1_\2')
          name.downcase!
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


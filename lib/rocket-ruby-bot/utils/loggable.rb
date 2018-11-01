module RocketRubyBot
  module Utils
    # log logic
    module Loggable
      def self.included(base)
        base.send :include, InstanceMethods
        base.extend(ClassMethods)
      end

      module ClassMethods
        def logger
          @logger ||= RocketRubyBot::Config.logger || begin
            $stdout.sync = true
            Logger.new($stdout)
          end
          
          @logger
        end
      end

      module InstanceMethods
        def logger
          self.class.logger
        end
      end
    end
  end
end

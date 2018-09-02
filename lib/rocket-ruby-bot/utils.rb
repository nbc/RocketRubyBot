module RocketRubyBot
  
  module MessageId
    private
    def next_id
      @next_id ||= 0
      @next_id += 1
      @next_id.to_s
    end
  end

  module UUID
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    module ClassMethods
      def uuid
        SecureRandom::hex
      end
    end
  end

  module Utils
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      
      def is_a_message?(data)
        return false unless data.key?('collection') and (data['collection'] == 'stream-room-messages')
        return false unless data['fields'].key?('args')

        message = data['fields']['args'].first

        # les messages n'ont pas d'argument 't'
        # https://github.com/mathieui/unha2/blob/master/docs/message.rst
        return false if message.key?('t')
        
        true
      end
    end

  end

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

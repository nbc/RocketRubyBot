module RocketRubyBot
  module Utils
    # unique id for talking with server
    module MessageId
      private

      def next_id
        @next_id ||= 0
        @next_id += 1
        @next_id.to_s
      end
    end

    # uuid methods
    module UUID
      def self.included(klass)
        klass.extend(ClassMethods)
      end
      module ClassMethods
        def uuid
          SecureRandom.hex
        end
      end
    end
  end
end

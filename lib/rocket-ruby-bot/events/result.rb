module RocketRubyBot
  module Events
    # class for result of methods and stream commands
    class Result
      attr_reader :id, :value
      
      def initialize(id:, value:)
        @id = id
        @value = value
      end

      def result?
        true
      end

      def token?
        value.respond_to?(:token) and true
      end

      def type
        return :authenticated if token?

        :result
      end
    end
  end
end

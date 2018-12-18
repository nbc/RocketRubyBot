module RocketRubyBot
  module Events
    class Result
      attr_reader :id, :value
      
      def initialize(id:, value:)
        @id, @value = id, value
      end

      def token?
        return true if value and value.respond_to?(:token)
      end

      def result?; true end

      def type
        return :authenticated if token?

        :result
      end
    end
  end
end

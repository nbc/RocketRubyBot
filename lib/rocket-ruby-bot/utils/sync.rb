module RocketRubyBot
  module Utils
    # module to "resync" messages with Fiber
    module Sync
      def self.fiber_store
        @fiber_store ||= {}
      end

      def create_fiber(id, &_block)
        f = Fiber.new do
          message = Fiber.yield
          yield message
        end
        Sync.fiber_store[id] = f
        f.resume
      end

      def resume_fiber(data)
        id = data.result_id
        return unless Sync.fiber_store.key? id

        fiber = Sync.fiber_store.delete id
        fiber.resume data
      end
    end
  end
end

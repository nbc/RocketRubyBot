module RocketRubyBot
  module Utils
    # module to "resync" messages with Fiber
    module Sync
      def self.fiber_store
        @fiber_store ||= {}
      end

      def event_fiber(&_block)
        Fiber.new { yield }.resume
      end
      
      def block_fiber(id, &_block)
        f = Fiber.new do
          message = Fiber.yield
          yield message
        end
        Sync.fiber_store[id] = f
        f.resume
      end

      def sync_fiber(id, &_block)
        Sync.fiber_store[id] = Fiber.current
        yield
        Fiber.yield
      end
      
      def resume_fiber(id, data)
        return unless Sync.fiber_store.key? id

        fiber = Sync.fiber_store.delete id
        fiber.resume data
      end

    end
  end
end

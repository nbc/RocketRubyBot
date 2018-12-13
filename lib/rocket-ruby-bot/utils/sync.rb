module RocketRubyBot
  module Utils
    # module to "resync" messages with Fiber
    module Sync
      def self.fiber_store
        @fiber_store ||= Hash.new
      end

      def event_fiber(&_block)
        Fiber.new { yield }.resume
      end
      
      def block_fiber(id, &_block)
        f = Fiber.new do
          message = Fiber.yield
          yield message
        end
        Sync.fiber_store[id] = OpenStruct.new fiber: f
        f.resume
      end

      def sync_fiber(id, method = false, &_block)
        Sync.fiber_store[id] = OpenStruct.new fiber: Fiber.current,
                                              parse_with: method
        yield
        Fiber.yield
      end
      
      def resume_fiber(id, data)
        return unless Sync.fiber_store.key? id

        obj = Sync.fiber_store.delete id
        obj.fiber.resume data
      end

      def self.parse_method(id)
        return Sync.fiber_store[id].parse_with if Sync.fiber_store.key?(id)
      end
    end
  end
end

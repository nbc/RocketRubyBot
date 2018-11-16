require_relative '../test_helpers'

require 'rocket-ruby-bot/utils/sync'

class TestSync < Minitest::Test
  def setup
    @klass = Class.new
    @klass.include RocketRubyBot::Utils::Sync
  end

  def test_block_and_resume
    id = '1'
    value = OpenStruct.new result_id: id, msg: 'test'
    
    obj = @klass.new
    obj.block_fiber(id) { |v| v }

    assert RocketRubyBot::Utils::Sync.fiber_store.key?(id)
    assert_instance_of Fiber, RocketRubyBot::Utils::Sync.fiber_store[id]

    assert_equal value, obj.resume_fiber(id, value)
    assert RocketRubyBot::Utils::Sync.fiber_store.empty?
  end

  def test_sync_and_resume
    id = '2'
    value = OpenStruct.new result_id: id, msg: 'test'
    obj = @klass.new

    result = nil
    Fiber.new do
      result = obj.sync_fiber(id) {}
    end.resume

    assert RocketRubyBot::Utils::Sync.fiber_store.key?(id)
    assert_instance_of Fiber, RocketRubyBot::Utils::Sync.fiber_store[id]
    
    obj.resume_fiber(id, value)
    assert_equal value, result
  end
  
  def test_resume_without_create
    mock = Minitest::Mock.new
    mock.expect(:result_id, '3', )

    obj = @klass.new
    assert_nil nil, obj.resume_fiber('3', mock)
  end
end

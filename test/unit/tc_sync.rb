require_relative '../test_helpers'

require 'rocket-ruby-bot/utils/sync'

class TestSync < Minitest::Test
  def setup
    @klass = Class.new
    @klass.include RocketRubyBot::Utils::Sync
  end

  def test_create_and_resume
    value = 'value'

    obj = @klass.new
    obj.create_fiber('1') { value }

    assert RocketRubyBot::Utils::Sync.fiber_store.key?('1')
    assert_instance_of Fiber, RocketRubyBot::Utils::Sync.fiber_store['1']
    
    mock = Minitest::Mock.new
    mock.expect(:result_id, '1')

    assert_equal value, obj.resume_fiber(mock)
    assert_mock mock
    assert RocketRubyBot::Utils::Sync.fiber_store.empty?
  end

  def test_resume_without_create
    mock = Minitest::Mock.new
    mock.expect(:result_id, '2')

    obj = @klass.new
    assert_nil nil, obj.resume_fiber(mock)
  end
end

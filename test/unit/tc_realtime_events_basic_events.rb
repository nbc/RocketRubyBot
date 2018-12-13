require_relative '../test_helpers'

require 'rocket-ruby-bot'
require 'ostruct'

class RealtimeEventsBasicEvents < MiniTest::Test
  def test_ping
    event = { 'msg': 'ping' }
    obj = build_event(event)
    assert_equal :ping, obj.type
  end

  def test_connected
    event = { 'msg': 'connected', 'session': 'session' }
    obj = build_event(event)
    assert_equal :connected, obj.type
    assert_equal 'session', obj.session
  end
  
  def test_ready
    event = { 'msg': 'ready', 'subs': ['3'] }
    obj = build_event(event)
    assert_equal :ready, obj.type
    assert_equal '3', obj.result_id
  end

  def test_updated
    event = { 'msg': 'updated', 'methods': ['1'] }
    obj = build_event(event)
    assert_equal :updated, obj.type
  end

  # def test_removed; end
  # def test_failed; end
  # def test_error; end

  def test_nosub
    event = { 'msg': 'nosub', 'id': 'id' }
    obj = build_event(event)
    assert_equal :nosub, obj.type
  end

  def test_added
    event = { 'msg': 'added', 'collection': 'users' }
    obj = build_event(event)
    assert_equal :added, obj.type
  end
  
  def build_event(event)
    RocketRubyBot::Realtime::Events::EventFactory.builder(to_openstruct(event))
  end
end

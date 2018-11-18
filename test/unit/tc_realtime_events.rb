require_relative '../test_helpers'

require 'json'
require 'rocket-ruby-bot/realtime/event'

class TestEvents < MiniTest::Test
  def setup
    RocketRubyBot::Config.logger = Logger.new StringIO.new
  end

  def test_coherence_events
    json = File.read('test/fixtures/events.json')
    hash = JSON.parse(json)

    hash.each_pair do |k, v|
      event = RocketRubyBot::Realtime::Event.new(v)
      assert_equal k.to_sym, event.type
    end
  end

  def test_result_id_for_subscription
    event = RocketRubyBot::Realtime::Event.new(msg: 'ready', subs: ['4'])
    assert_equal '4', event.result_id
  end

  def test_result_id_for_other
    event = RocketRubyBot::Realtime::Event.new(msg: 'result', id: '2', result: 'GENERAL')
    assert_equal '2', event.result_id
  end

  def test_ping
    event = RocketRubyBot::Realtime::Event.new(msg: 'ping')
    assert_equal true, event.ping?
  end

  def test_unknown_event
    event = RocketRubyBot::Realtime::Event.new(msg: 'unknown')
    var = false
    event.yield_unless_seen { var = true }
    assert_equal true, var
  end
end

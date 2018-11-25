require_relative '../test_helpers'

require 'json'
require 'rocket-ruby-bot/realtime/events'

class TestEvents < MiniTest::Test
  def setup
    RocketRubyBot::Config.logger = Logger.new StringIO.new
  end

  def test_coherence_events
    json = File.read('test/fixtures/events.json')
    hash = JSON.parse(json)

    hash.each_pair do |k, v|
      event = RocketRubyBot::Realtime::Events::EventFactory.builder v.to_json
      assert_equal k.to_sym, event.type
    end
  end

  def test_result_id_for_subscription
    event = RocketRubyBot::Realtime::Events::EventFactory.builder({ msg: 'ready', subs: ['4'] }.to_json)
    assert_equal '4', event.result_id
  end

  def test_result_id_for_other_commands
    event = RocketRubyBot::Realtime::Events::EventFactory.builder({ msg: 'result', id: '2', result: 'GENERAL' }.to_json)
    assert_equal '2', event.result_id
  end

  def test_log_unknown_event
    # FIXME
    RocketRubyBot::Realtime::Events::EventFactory.builder({ msg: 'unknown' }.to_json)
  end
end

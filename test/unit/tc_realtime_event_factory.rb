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
      event = RocketRubyBot::Realtime::Events::EventFactory.builder to_openstruct(v)
      assert_equal k.to_sym, event.type
    end
  end

  def test_result_id_for_subscription
    skip "no longer like that"
    event = RocketRubyBot::Realtime::Events::EventFactory.builder(to_openstruct({ msg: 'ready', subs: ['4'] }))
    assert_equal '4', event.result_id
  end

  def test_result_id_for_other_commands
    skip "no longer like that"
    event = RocketRubyBot::Realtime::Events::EventFactory.builder(to_openstruct({ msg: 'result', id: '2', result: 'GENERAL' }))
    assert_equal '2', event.result_id
  end

  def test_log_unknown_event
    # FIXME
    RocketRubyBot::Realtime::Events::EventFactory.builder(to_openstruct({ msg: 'unknown' }))
  end
end

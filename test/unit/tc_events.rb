require_relative '../test_helpers'

require 'json'
require 'rocket-ruby-bot/realtime/event'

class TestEvents < MiniTest::Test

  def test_coherence_events
    json = File.read('test/fixtures/events.json')
    hash = JSON.parse(json)

    hash.each_pair do |k, v|
      event = RocketRubyBot::Realtime::Event.new(v)
      assert_equal event._type, k.to_sym
    end
  end
end

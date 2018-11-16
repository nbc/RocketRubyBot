require_relative '../test_helpers'

require 'rocket-ruby-bot'

class EventsPing < MiniTest::Test

  def test_ping
    @event = RocketRubyBot::Events::Ping.new
    client = Minitest::Mock.new
    client.expect :send_json, nil, [{ msg: 'pong' }]
    
    @event.call(client, nil)

    assert_mock client
  end
end

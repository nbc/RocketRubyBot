require_relative '../test_helpers'

require 'rocket-ruby-bot'

class EventsConnected < MiniTest::Test

  def setup
    RocketRubyBot::Config.token = 'a token'
    @event = RocketRubyBot::Events::Connected.new
    @client = Class.new
  end
  
  def test_connected
    # rubocop:disable Lint/NestedMethodDefinition
    def @client.say(_data)
      yield RocketRubyBot::Realtime::Event.new(msg: 'result',
                                               result: { id: 'an id' })
    end
    # rubocop:enable Lint/NestedMethodDefinition
    
    @event.call(@client, nil)
    assert_equal 'an id', RocketRubyBot::Config.user_id
  end

  def test_connection_error
    # rubocop:disable Lint/NestedMethodDefinition
    def @client.say(_data)
      yield RocketRubyBot::Realtime::Event.new(msg: 'result',
                                               error: { message: 'a reason' })
    end
    # rubocop:enable Lint/NestedMethodDefinition
    
    assert_raises('a reason') { @event.call(@client, nil) }
  end
end

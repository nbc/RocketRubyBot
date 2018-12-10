require_relative '../test_helpers'

require 'rocket-ruby-bot'

class HooksConnected < MiniTest::Test

  def setup
    RocketRubyBot::Config.token = 'a token'
    RocketRubyBot::Config.logger = Logger.new StringIO.new
    @event = RocketRubyBot::Hooks::Connected.new
    @client = Class.new
  end
  
  def test_connected
    # rubocop:disable Lint/NestedMethodDefinition
    def @client.say(_data)
      yield RocketRubyBot::Realtime::Events::EventFactory.builder({ msg: 'result',
                                                                    result: { id: 'an id' }}.to_json)
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

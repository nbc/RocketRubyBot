require_relative '../test_helpers'

require 'rocket-ruby-bot'

class EventsBase < MiniTest::Test
  def test_event_hooks
    assert RocketRubyBot::Events::Base.event_hooks.key? :ping
  end
  
  def test_register
    @class = Class.new RocketRubyBot::Events::Base
    @class.register :another_key
    assert RocketRubyBot::Events::Base.event_hooks.key? :another_key
  end
end

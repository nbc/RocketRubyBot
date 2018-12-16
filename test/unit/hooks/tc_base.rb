require_relative '../../test_helpers'

require 'rocket-ruby-bot'

class HooksBase < MiniTest::Test
  def test_hooks
    assert RocketRubyBot::Hooks::Base.event_hooks.key? :ping
  end
  
  def test_register
    @class = Class.new RocketRubyBot::Hooks::Base
    @class.register :another_key
    assert RocketRubyBot::Hooks::Base.event_hooks.key? :another_key
  end
end

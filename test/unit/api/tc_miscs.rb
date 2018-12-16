require_relative '../../test_helpers'

require 'json'
require 'rocket-ruby-bot/api'

class TestRealtimeApi < Minitest::Test
  include RocketRubyBot::API::Miscs

  def test_pong
    assert_equal send_pong, { msg: 'pong' }
  end
end

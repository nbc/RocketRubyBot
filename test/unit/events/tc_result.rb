require_relative '../../test_helpers'

require 'rocket-ruby-bot'
require 'ostruct'

class TestResult < MiniTest::Test
  def test_token_and_type
    event = RocketRubyBot::Events::Result.new id: '1',
                                              value: OpenStruct.new(token: 'token')
    assert event.token?
    assert_equal :authenticated, event.type

    event = RocketRubyBot::Events::Result.new id: '1',
                                              value: OpenStruct.new
    assert !event.token?
    assert_equal :result, event.type
  end

  def test_result?
    event = RocketRubyBot::Events::Result.new id: '1',
                                              value: OpenStruct.new
    assert event.result?
  end

end

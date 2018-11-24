require_relative '../test_helpers'

require 'ostruct'
require 'json'
require 'rocket-ruby-bot/realtime/events'

module Test
  class CamelCase
    include RocketRubyBot::Realtime::Events::Utils
  end
end

class AnotherCase
  include RocketRubyBot::Realtime::Events::Utils
end

class TestEventsUtils < MiniTest::Test
  def test_snake_case
    res = Test::CamelCase.new.class_to_snake_case
    assert_equal 'camel_case', res
    res = AnotherCase.new.class_to_snake_case 
    assert_equal 'another_case', res
  end

  def test_to_timestamp
    ts = 1550798316521
    date = Time.at(ts / 1000)
    a = OpenStruct.new '$date': ts

    assert_equal date, AnotherCase.new.to_timestamp(a)
  end

  def test_user_actor
    klass = Class.new do
      attr_accessor :u, :msg
      include RocketRubyBot::Realtime::Events::UserActor
    end
    obj = klass.new
    obj.u, obj.msg = 'u', 'msg'

    assert_equal 'u', obj.actor
    assert_equal 'msg', obj.user
  end
  
end

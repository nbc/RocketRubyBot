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

  def test_class_to_snake_case
    res = Test::CamelCase.new.class_to_snake_case 
    assert_equal :camel_case, res
    res = AnotherCase.new.class_to_snake_case 
    assert_equal :another_case, res
  end

  def test_to_snake_case
    klass = Class.new.include RocketRubyBot::Realtime::Events::Utils
    obj = klass.new

    assert_equal 'users_name_changed', obj.to_snake_case('Users:NameChanged')
    assert_equal 'users', obj.to_snake_case('users')
  end
  
  def test_ts_to_datetime
    ts = 1550798316521
    date = Time.at(ts / 1000)
    a = OpenStruct.new '$date': ts

    assert_equal date, AnotherCase.new.ts_to_datetime(a)
  end

  def test_extract_type
    klass = Class.new.include RocketRubyBot::Realtime::Events::Utils
    obj = klass.new
    
    res = obj.extract_type('simple')
    assert_equal 'simple', res

    res = obj.extract_type('complex/event-name')
    assert_equal 'event_name', res
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

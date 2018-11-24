require_relative '../test_helpers'

require 'ostruct'
require 'json'
require 'rocket-ruby-bot/realtime/events'

class TestStreamNotify < MiniTest::Test
  def test_stream_notify_logged
    obj = OpenStruct.new(fields: OpenStruct.new(eventName: 'truc'))
    stream = RocketRubyBot::Realtime::Events::StreamNotifyLogged.new obj
    assert_equal :truc, stream.type
  end

  def test_stream_notify_all
    obj = OpenStruct.new(fields: OpenStruct.new(eventName: 'truc'))
    stream = RocketRubyBot::Realtime::Events::StreamNotifyAll.new obj
    assert_equal :truc, stream.type
  end

  def test_stream_notify_user
    obj = OpenStruct.new(fields: OpenStruct.new(eventName: 'machin/tr-uc'))
    stream = RocketRubyBot::Realtime::Events::StreamNotifyUser.new obj
    assert_equal :tr_uc, stream.type
  end

  def test_stream_notify_room
    obj = OpenStruct.new(fields: OpenStruct.new(eventName: 'machin/tr-uc'))
    stream = RocketRubyBot::Realtime::Events::StreamNotifyRoom.new obj
    assert_equal :tr_uc, stream.type
  end
end

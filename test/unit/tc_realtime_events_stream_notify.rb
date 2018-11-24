require_relative '../test_helpers'

require 'ostruct'
require 'json'
require 'rocket-ruby-bot/realtime/events'

class TestStreamNotify < MiniTest::Test

  def setup
    @obj = OpenStruct.new(fields: OpenStruct.new(eventName: 'truc'))
  end
  
  def test_stream_notify_logged
    stream = RocketRubyBot::Realtime::Events::StreamNotifyLogged.new @obj
    assert stream.type
  end

  def test_stream_notify_all
    stream = RocketRubyBot::Realtime::Events::StreamNotifyAll.new @obj
    assert stream.type
  end

  def test_stream_notify_user
    stream = RocketRubyBot::Realtime::Events::StreamNotifyUser.new @obj
    assert stream.type
  end

  def test_stream_notify_room
    stream = RocketRubyBot::Realtime::Events::StreamNotifyRoom.new @obj
    assert stream.type
  end
end

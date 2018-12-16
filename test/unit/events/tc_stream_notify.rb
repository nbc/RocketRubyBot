require_relative '../../test_helpers'

require 'ostruct'
require 'json'
require 'rocket-ruby-bot/events'

class TestStreamNotify < MiniTest::Test

  def setup
    @obj = OpenStruct.new(fields: OpenStruct.new(eventName: 'truc', args:['updated']))
  end
  
  def test_stream_notify_logged
    stream = RocketRubyBot::Events::StreamNotifyLogged.new @obj
    assert stream.type
  end

  def test_stream_notify_all
    stream = RocketRubyBot::Events::StreamNotifyAll.new @obj
    assert stream.type
  end

  def test_stream_notify_room
    stream = RocketRubyBot::Events::StreamNotifyRoom.new @obj
    assert stream.type
  end
end

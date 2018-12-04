require_relative '../test_helpers'

require 'ostruct'
require 'json'
require 'rocket-ruby-bot/realtime/events'

class TestStreamNotifyuser < MiniTest::Test
  def test_added_to_group
    inserted = {"msg":"changed",
                "collection":"stream-notify-user",
                "fields":{"eventName":"a/subscriptions-changed",
                          "args":["inserted",{"rid":"room_id"}]}}
    stream = RocketRubyBot::Realtime::Events::EventFactory.builder inserted.to_json
    assert stream.type
  end

  def test_added_to_group
    inserted = {"msg":"changed",
                "collection":"stream-notify-user",
                "fields":{"eventName":"a/subscriptions-changed",
                          "args":["inserted",{"rid":"room_id"}]}}
    stream = RocketRubyBot::Realtime::Events::EventFactory.builder inserted.to_json
    assert_equal 'room_id', stream.added_to_group
  end
  
  def test_not_added_to_group
    not_inserted = {"msg":"changed",
                    "collection":"stream-notify-user",
                    "fields":{"eventName":"a/subscriptions-changed", "args":['updated', { 't':'d' }] } }
    stream = RocketRubyBot::Realtime::Events::EventFactory.builder not_inserted.to_json
    assert_nil stream.added_to_group
  end

end

require_relative '../test_helpers'

require 'rocket-ruby-bot'

class EventsMessage < MiniTest::Test

  def setup
    @class = Class.new
    @class.extend RocketRubyBot::Routes

    message = {"msg":"changed","collection":"stream-room-messages",
               "fields": {"args":[{"msg":"THIS_BOT TEXT here",
                                   "u":{"_id": 'id'}}]}}
    @message = RocketRubyBot::Realtime::Event.new message

  end

  def teardown
    @class.routes = []
  end

  def test_message_from_self
    @class.match(/text/) {}
    @event = RocketRubyBot::Events::Message.new routes: @class.routes
    RocketRubyBot.configure do |config|
      config.user_id = 'id'
    end
    assert_nil @event.call(Object.new, @message)
  end
  
  def test_empty_routes
    @event = RocketRubyBot::Events::Message.new routes: []
    RocketRubyBot.configure do |config|
      config.user_id = 'other_user_id'
    end
    assert_nil @event.call(Object.new, @message)
  end

  def test_match_from_other
    @class.match(/text/) do |client|
      client.send_message
    end
    @event = RocketRubyBot::Events::Message.new routes: @class.routes
    RocketRubyBot.configure do |config|
      config.user_id = 'other_user_id'
    end
    client = Minitest::Mock.new
    client.expect :send_message, '', []
    assert_equal @class.routes.first, @event.call(client, @message)
    assert_mock client
  end

  def test_command_for_other_bot
    @class.command(/text/) {}
    @event = RocketRubyBot::Events::Message.new(routes: @class.routes)
    RocketRubyBot::configure do |config|
      config.user_id = 'other_user_id'
      config.user = 'other_bot'
    end
    client = RocketRubyBot::Realtime::Client.new nil, nil
    assert_nil @event.call(client, @message)
  end

  def test_command_for_this_bot
    @class.command(/text/) {}
    @event = RocketRubyBot::Events::Message.new(routes: @class.routes)
    RocketRubyBot::configure do |config|
      config.user_id = 'other_user_id'
      config.user = 'this_bot'
    end
    client = RocketRubyBot::Realtime::Client.new nil, nil
    assert_equal @class.routes.first, @event.call(client, @message)
  end
end

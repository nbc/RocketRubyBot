require_relative '../test_helpers'

require 'rocket-ruby-bot'

class EventsMessage < MiniTest::Test

  def setup
    @class = Class.new
    @class.extend RocketRubyBot::Routes

    message = {"msg": "changed","collection": "stream-room-messages",
               "fields": {"args": [{"msg": "THIS_BOT TEXT here",
                                   "u": {"_id": 'id'}}]}}
    @message = RocketRubyBot::Realtime::Event.new message
    @event = RocketRubyBot::Events::Message.new routes: []
  end

  def teardown
    @class.routes = []
    RocketRubyBot::Config.bot_names = nil
  end

  def test_message_from_self
    @class.match(/text/) {}
    @event.routes =  @class.routes
    RocketRubyBot::Config.user_id = 'id'

    ret = @event.call(Object.new, @message)
    
    assert_nil ret
  end
  
  def test_empty_routes
    @event.routes = []
    RocketRubyBot::Config.user_id = 'other_user_id'

    ret = @event.call(Object.new, @message)

    assert_nil ret
  end

  def test_match_from_other
    @class.match(/text/) do |client|
      client.send_message
    end
    @event.routes = @class.routes
    RocketRubyBot::Config.user_id = 'other_user_id'
    client = Minitest::Mock.new
    client.expect :send_message, '', []

    ret = @event.call(client, @message)
    
    assert_equal @class.routes.first, ret
    assert_mock client
  end

  def test_command_for_other_bot
    @class.command('text') {}
    @event.routes = @class.routes

    RocketRubyBot::configure do |config|
      config.user_id = 'other_user_id'
      config.user = 'other_bot'
    end
    client = RocketRubyBot::Realtime::Client.new nil, nil

    ret = @event.call(client, @message)

    assert_nil ret
  end

  def test_command_for_this_bot
    @class.command('text') {}
    @event.routes = @class.routes
    RocketRubyBot::configure do |config|
      config.user_id = 'other_user_id'
      config.user = 'this_bot'
    end
    client = RocketRubyBot::Realtime::Client.new nil, nil

    ret = @event.call(client, @message)
    
    assert_equal @class.routes.first, ret
  end
end

require_relative '../test_helpers'

class TestBot < MiniTest::Test

  def setup
    RocketRubyBot::Config.token = 'a bot token'
    RocketRubyBot::Config.user = 'my_bot' 

    @class = Class.new RocketRubyBot::Bot
    @object = @class.new
  end
  
  def test_web_client
    assert_instance_of RocketChat::Session, @class.web_client
    assert_instance_of RocketChat::Session, @object.web_client
  end

  def test_user_store
    assert_instance_of Hashie::Mash, @class.user_store
    assert_instance_of Hashie::Mash, @object.user_store
  end

  def test_routes
    @class.match(/test/) {}
    @class.command('command') {}

    assert_equal /test/i, @class.routes.first[:regexp]
    assert_match 'command', @class.routes.last[:regexp].to_s
  end
  
  def teardown
    RocketRubyBot::Config.token = nil
    RocketRubyBot::Config.user = nil
    @class.routes = []
    @class = nil
  end
end

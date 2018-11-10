require_relative '../test_helpers'

class TestBot < MiniTest::Test

  def setup
    RocketRubyBot::Config.token = 'a bot token'
    @klass = Class.new(RocketRubyBot::Bot)
    @object = @klass.new
  end
  
  def test_web_client
    assert_instance_of RocketChat::Session, @klass.web_client
    assert_instance_of RocketChat::Session, @object.web_client
  end

  def test_user_store
    assert_instance_of Hashie::Mash, @klass.user_store
    assert_instance_of Hashie::Mash, @object.user_store
  end

  def teardown
    RocketRubyBot::Config.token = nil
  end
end

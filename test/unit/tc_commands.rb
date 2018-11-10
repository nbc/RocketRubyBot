require_relative '../test_helpers'

class TestCommands < Minitest::Test

  def setup
    RocketRubyBot::Config.url = 'https://my.server/'
    @class = Class.new(RocketRubyBot::Commands)
  end

  def test_config
    assert_kind_of RocketRubyBot::Config, @class.config
  end

  def test_hooks
    assert @class.hooks.key? :ping
  end

  def test_on_event
    @class.on_event :test do
    end
    assert @class.hooks.key? :test
    assert_kind_of Array, @class.hooks[:test]
  end

  def test_setup
    value = false
    @class.setup do
      value = true
    end
    assert @class.hooks.key? :authenticated

    @class.hooks[:authenticated].first.call
    assert value
  end

  def test_closing
    value = false
    @class.closing do
      value = true
    end
    assert @class.hooks.key? :closing
    @class.hooks[:closing].first.call
    assert value
  end

  def teardown
    RocketRubyBot::Config.url = nil
    RocketRubyBot::Config.websocket_url = nil
  end
  
end

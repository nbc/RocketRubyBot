require_relative '../test_helpers'

require 'rocket-ruby-bot/config'

class TestConfig < MiniTest::Test

  def test_https_url
    RocketRubyBot::Config.url = "https://my.server"
    assert_equal 'wss://my.server/websocket', RocketRubyBot::Config.websocket_url
  end

  def test_http_url
    RocketRubyBot::Config.url = "http://my.server"
    assert_equal 'ws://my.server/websocket', RocketRubyBot::Config.websocket_url
  end

  def test_http_url_with_ending_slash
    RocketRubyBot::Config.url = "http://my.server/"
    assert_equal 'ws://my.server/websocket', RocketRubyBot::Config.websocket_url
  end
  
  def test_websocket_url
    RocketRubyBot::Config.websocket_url = "ws://my.other.server/websocket"
    RocketRubyBot::Config.url = "http://my.server"
    assert_equal "ws://my.other.server/websocket", RocketRubyBot::Config.websocket_url
  end

  def teardown
    RocketRubyBot::Config.websocket_url = nil
    RocketRubyBot::Config.url = nil
  end
  
end

require_relative '../test_helpers'

require 'rocket-ruby-bot/config'

class TestConfig < MiniTest::Test

  def test_https_url
    RocketRubyBot::Config.url = 'https://my.server'
    assert_equal 'wss://my.server/websocket', RocketRubyBot::Config.websocket_url
  end

  def test_http_url
    RocketRubyBot::Config.url = 'http://my.server'
    assert_equal 'ws://my.server/websocket', RocketRubyBot::Config.websocket_url
  end

  def test_http_url_with_ending_slash
    RocketRubyBot::Config.url = 'http://my.server/'
    assert_equal 'ws://my.server/websocket', RocketRubyBot::Config.websocket_url
  end
  
  def test_websocket_url
    RocketRubyBot::Config.websocket_url = 'ws://my.other.server/websocket'
    RocketRubyBot::Config.url = 'http://my.server'
    assert_equal 'ws://my.other.server/websocket', RocketRubyBot::Config.websocket_url
  end

  def test_no_token_in_env
    ClimateControl.modify ROCKET_API_TOKEN: nil do 
      assert_raises('Missing ENV["ROCKET_API_TOKEN"].') { RocketRubyBot::Config.token }
    end
  end
  
  def test_token_in_env
    ClimateControl.modify ROCKET_API_TOKEN: 'a token' do
      assert_equal 'a token', RocketRubyBot::Config.token
    end
  end

  def test_token_in_config
    ClimateControl.modify ROCKET_API_TOKEN: 'a token' do
      RocketRubyBot::Config.token = 'another token'
      assert_equal 'another token', RocketRubyBot::Config.token
    end
  end
  
  def teardown
    RocketRubyBot::Config.websocket_url = nil
    RocketRubyBot::Config.url = nil
    RocketRubyBot::Config.token = nil
  end
end

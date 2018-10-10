require_relative '../test_helpers'

require 'hashie'

require 'rocket-ruby-bot/utils'
require 'rocket-ruby-bot/realtime/client'
require 'rocket-ruby-bot/realtime/api'
require 'rocket-ruby-bot/server'
require 'rocket-ruby-bot/hooks'
require 'rocket-ruby-bot/config'



class TestServer < Minitest::Test

  def setup
    @config = Hashie::Mash.new do |c|
      c.token = 'a token'
      c.websocket_url = 'wss://my.site/websocket'
      c.user_id = 'a user id'
    end
  end
  
  def test_initialize_with_real_client
    server = RocketRubyBot::Server.new(config: @config)
    assert_equal @config.websocket_url, server.websocket_url

    assert_instance_of RocketRubyBot::Realtime::Client, server.client
    assert server.hooks.has_key? :ping
    assert_instance_of RocketRubyBot::Hooks::Ping, server.hooks[:ping].first
  end

  def test_with_mock_run
    server = RocketRubyBot::Server.new(config: @config)
    mock = Minitest::Mock.new
    server.client(client: mock)

    mock.expect(:start, nil, [])
    mock.expect(:stop, nil, [])

    server.start!
    server.stop!

    assert_mock mock
  end
end

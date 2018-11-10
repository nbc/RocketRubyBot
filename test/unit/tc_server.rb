require_relative '../test_helpers'

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
    assert server.hooks.key? :ping
    assert_instance_of RocketRubyBot::Events::Ping, server.hooks[:ping].first
  end

  def test_with_mock_run
    server = RocketRubyBot::Server.new(config: @config)
    client = Minitest::Mock.new
    client.expect(:start, nil, [])
    client.expect(:stop, nil, [])

    server.client(client: client)

    server.start!
    server.stop!

    assert_mock client
  end

  def test_signal_handler
    # server = RocketRubyBot::Server.new(config: @config)
    # signal_handler = Minitest::Mock.new
    # signal_handler.expect(:call, nil, [])

    # client = Minitest::Mock.new
    # client.expect(:start, nil, [])

    # server.stub :signal_handler, signal_handler do
    #  server.trap_signals
    #  server.client(client: client)
    #  Process.kill 'TERM', 0
    # end
    
    # assert_mock signal_handler
  end

end

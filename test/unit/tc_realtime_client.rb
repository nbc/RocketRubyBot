require_relative '../test_helpers'

require 'rocket-ruby-bot'
require 'ostruct'

class RealtimeClient < MiniTest::Test
  def setup
    RocketRubyBot::Config.logger = Logger.new StringIO.new
    @client = RocketRubyBot::Realtime::Client.new(nil, nil)
  end
  
  def test_on_close
    event = OpenStruct.new :code => "", :reason => ""
    result = false
    
    @client.exec_on_close { result = true }
    @client.on_close(event)

    assert result
  end
  
  def test_web_socket
    assert_instance_of Faye::WebSocket::Client, @client.web_socket
  end

  def test_send_json
    mock = Minitest::Mock.new
    mock.expect :send, nil, ['""']
    @client.web_socket = mock
    
    @client.send_json ''

    assert_mock mock
  end

  def test_empty_say
    mock = Minitest::Mock.new
    mock.expect :send, nil, [{id: '1'}.to_json]
    @client.web_socket = mock

    @client.say( {} )

    assert_mock mock
  end
  
  def test_say
    mock = Minitest::Mock.new
    mock.expect :send, nil, [{id: '1', arg: 'arg'}.to_json]
    @client.web_socket = mock
    
    @client.say({ arg: 'arg' })

    assert_mock mock
  end
  
  def test_say_with_block
    mock = Minitest::Mock.new
    mock.expect :send, nil, [{id: '1', arg: 'arg'}.to_json]
    @client.web_socket = mock
    
    @client.say({ arg: 'arg' }) {}

    assert_mock mock
    assert RocketRubyBot::Utils::Sync.fiber_store.key?('1')
    assert_instance_of Fiber, RocketRubyBot::Utils::Sync.fiber_store['1']
  end

  def test_on_open
    mock = Minitest::Mock.new
    mock.expect :send, nil, [RocketRubyBot::Realtime::API.connect.to_json]
    @client.web_socket = mock
    
    @client.on_open

    assert_mock mock
  end

  def test_dispatch_event
    message = RocketRubyBot::Realtime::Event.new({ "msg": "ping" })
    mock = Minitest::Mock.new
    mock.expect :call, '', [@client, message ]
    @client.hooks = { ping: [mock] }
    
    @client.dispatch_event message

    assert_mock mock
  end

  def test_on_message
    message = RocketRubyBot::Realtime::Event.new({ "msg": "ping" })
    event = OpenStruct.new :data => { "msg": "ping" }.to_json
    mock = Minitest::Mock.new
    mock.expect :call, '', [@client, message]
    @client.hooks = { ping: [mock] }
    
    @client.on_message(event)

    assert_mock mock
  end

  def test_stop
    hook = Minitest::Mock.new
    hook.expect :call, '', [@client, '']
    web_socket = Minitest::Mock.new
    web_socket.expect :close, '', []
    @client.web_socket = web_socket
    @client.hooks = { closing: [hook] }

    @client.stop
    
    assert_mock hook
    assert_mock web_socket
  end

  def teardown
    @client.hooks = {}
  end
end

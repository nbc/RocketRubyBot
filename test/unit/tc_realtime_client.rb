require_relative '../test_helpers'

require 'rocket-ruby-bot'
require 'ostruct'

class RealtimeClient < MiniTest::Test

  def setup
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
    
    @client.stub :web_socket, mock do
      @client.send_json ''
    end
    assert_mock mock
  end

  def test_empty_say
    mock = Minitest::Mock.new
    mock.expect :send, nil, [{id:'1'}.to_json]
    
    @client.stub :web_socket, mock do
      @client.say( {} )
    end
    assert_mock mock
  end
  
  def test_say
    mock = Minitest::Mock.new
    mock.expect :send, nil, [{id:'1', arg: 'arg'}.to_json]
    
    @client.stub :web_socket, mock do
      @client.say({ arg: 'arg' })
    end
    assert_mock mock
  end
  
  def test_say_with_block
    mock = Minitest::Mock.new
    mock.expect :send, nil, [{id:'1', arg: 'arg'}.to_json]
    
    @client.stub :web_socket, mock do
      @client.say({ arg: 'arg' }) {}
    end
    assert_mock mock
    assert RocketRubyBot::Utils::Sync.fiber_store.key?('1')
    assert_instance_of Fiber, RocketRubyBot::Utils::Sync.fiber_store['1']
  end

  def test_on_open
    logger = Minitest::Mock.new
    logger.expect :debug, nil, [':open']

    mock = Minitest::Mock.new
    mock.expect :send, nil, [RocketRubyBot::Realtime::API.connect.to_json]
    
    @client.stub :web_socket, mock do
      @client.on_open
    end
    assert_mock mock
  end
end

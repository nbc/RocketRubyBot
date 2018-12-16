require_relative '../../test_helpers'

require 'json'
require 'rocket-ruby-bot/rest/client'

class TestEvents < MiniTest::Test
  
  def test_rest_client
    client = RocketRubyBot::Rest::Client.session(url: 'url', token: 'token', user_id: 'id')
   
    assert_instance_of RocketChat::Session, client

    assert_equal 'url',   client.server.server.to_s
    assert_equal 'token', client.token.auth_token
    assert_equal 'id',    client.token.user_id

    assert_respond_to client, :groups
  end
end

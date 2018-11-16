require_relative '../test_helpers'

require 'json'
require 'rocket-ruby-bot/realtime/api'

class TestRealtimeApi < Minitest::Test
  include RocketRubyBot::Realtime::API
  extend RocketRubyBot::Realtime::API
  
  def test_login_with_digest
    assert_equal login(username: 'name', digest: 'digest'),
                 { msg: 'method',
                   method: 'login',
                   params: [{ user: { username: 'name' },
                              password: { digest: 'digest', algorithm: 'sha-256' } }] }
  end

  def test_login_with_token
    assert_equal login(token: 'token'),
                 { msg: 'method',
                   method: 'login',
                   params: [{ resume: 'token' }] }
  end

  def test_login_with_everything
    assert_equal login(username: 'name', digest: 'digest', token: 'token'),
                 { msg: 'method',
                   method: 'login',
                   params: [{ resume: 'token' }] }
  end
  
  def test_login_with_nothing
    assert_raises ArgumentError do
      login(some: 'argument')
    end
  end

  def test_register_user
    value = { msg: 'method',
              method: 'registerUser',
              params: [{ email: 'string',
                         pass: 'string',
                         name: 'string' }] }
    assert_equal register_user(email: 'string', pass: 'string', name: 'string'), value
  end

  def test_register_user_with_secret_url
    value = { msg: 'method',
              method: 'registerUser',
              params: [{ email: 'string',
                         pass: 'string',
                         name: 'string',
                         secretURL: 'string' }] }
    assert_equal register_user(email: 'string',
                               pass: 'string',
                               name: 'string',
                               secret_url: 'string'), value
  end

  def test_get_user_roles
    value = { msg: 'method',
              method: 'getUserRoles',
              params: [] }
    assert_equal get_user_roles, value
  end

  def test_get_public_settings
    value = { msg: 'method',
              method: 'public-settings/get' }
    assert_equal get_public_settings, value
  end

  def test_room_roles
    value = { msg: 'method',
              method: 'getRoomRoles',
              params: ['id'] }

    assert_equal room_roles(room_id: value[:params].first), value
  end

  def test_get_subscriptions
    assert_equal get_subscriptions,
                 { msg: 'method',
                   method: 'subscriptions/get',
                   params: [{ '$date': 0 }] }
    
    value = { msg: 'method',
              method: 'subscriptions/get',
              params: [{ '$date': 100009 }] }
    assert_equal get_subscriptions(since: value[:params].first[:$date]), value
  end

  def test_get_rooms
    assert_equal get_rooms,
                 { msg: 'method',
                   method: 'rooms/get',
                   params: [{ '$date': 0 }] }

    value = { msg: 'method',
              method: 'rooms/get',
              params: [{ '$date': 100009 }] }
    assert_equal get_rooms(since: value[:params].first[:$date]), value
  end

  def test_get_permissions
    assert_equal get_permissions,
                 { msg: 'method',
                   method: 'permissions/get',
                   params: [] }
  end

  def test_set_presence
    assert_equal set_presence(status: 'offline'), 
                 { msg: 'method',
                   method: 'UserPresence:setDefaultStatus',
                   params: ['offline'] }

    assert_raises ArgumentNotAllowed do
      set_presence(status: 'not here')
    end
  end

  def test_create_direct_message
    value =      { msg: 'method',
                   method: 'createDirectMessage',
                   params: ['nc'] }
    assert_equal create_direct_message(username: value[:params].first), value
  end

  def test_create_channel
    assert_equal create_channel(name: 'test', users: ['a', 'b', 'c'], read_only: false),
                 { msg: 'method',
                   method: 'createChannel',
                   params: ['test', ['a', 'b', 'c'], false] }

    assert_raises ArgumentNotAllowed do
      create_channel(name: 'test', users: 'a', read_only: false)
    end
  end

  def test_create_private_group
    assert_equal create_private_group(name: 'test', users: ['a', 'b', 'c']),
                 { msg: 'method',
                   method: 'createPrivateGroup',
                   params: ['test', ['a', 'b', 'c']] }

    assert_raises ArgumentNotAllowed do
      create_private_group(name: 'test', users: 'a')
    end
  end

  def test_bulk_methods
    methods = %w<erase_room archive_room unarchive_room leave_room hide_room open_room>

    value = { msg: 'method',
              method: nil,
              params: ['id'] }
    
    methods.each do |m|
      rc_method = m.gsub(/_./, 'R')
      value[:method] = rc_method
      assert_equal send(m, room_id: 'id'), value
    end
  end

  def test_join_channel
    assert_equal join_channel(room_id: 'id'),
                 { msg: 'method',
                   method: 'joinRoom',
                   params: ['id'] }

    assert_equal join_channel(room_id: 'id', join_code: 'code'),
                 { msg: 'method',
                   method: 'joinRoom',
                   params: ['id', 'code'] }
  end

  def test_send_message
    assert_equal send_message(room_id: 'id', msg: 'test', message_id: 'uuid'),
                 { msg: 'method',
                   method: 'sendMessage',
                   'params': [{ message_id: 'uuid', rid: 'id', msg: 'test' }] }
  end

  def test_load_history
    assert_equal load_history(room_id: 'id'), 
                 { msg: 'method',
                   method: 'loadHistory',
                   params: ['id', nil, 50, { '$date': 0 }] }
  end

  def test_pong
    assert_equal send_pong, { msg: 'pong' }
  end

  def test_stream_notify_all
    assert_equal stream_notify_all(sub: 'roles-change'),
                 { msg: 'sub',
                   name: 'stream-notify-all',
                   params:['roles-change', false] }

    assert_raises ArgumentNotAllowed do
      stream_notify_all(sub: 'bad_argument')
    end
  end

  def test_stream_notify_logged
    assert_equal stream_notify_logged(sub: 'roles-change'),
                 { msg: 'sub',
                   name: 'stream-notify-logged',
                   params:['roles-change', false] }

    assert_raises ArgumentNotAllowed do
      stream_notify_logged(sub: 'bad_argument')
    end
  end

  def test_stream_notify_room_users
    assert_equal stream_notify_room_users(room_id: 'room_id', sub: 'webrtc'),
                 { msg: 'sub',
                   name: 'stream-notify-room-users',
                   params: ['room_id/webrtc', false] }

    assert_raises ArgumentNotAllowed do
      stream_notify_room_users(room_id: '', sub: 'sub')
    end
  end
  
  def test_stream_notify_user
    assert_equal stream_notify_user(user_id: 'id', sub: 'notification'),
                 { msg: 'sub',
                   name: 'stream-notify-user',
                   params: ['id/notification' , false] }
    
    assert_raises ArgumentNotAllowed do
      stream_notify_user(user_id: 'id', sub: 'test')
    end
  end

  def test_stream_notify_room
    assert_equal stream_notify_room(room_id: 'room_id', sub: 'typing'),
                 { msg: 'sub',
                   name: 'stream-notify-room',
                   params: ['room_id/typing', false] }

    assert_raises ArgumentNotAllowed do
      stream_notify_room(room_id: 'room_id', sub: 'other')
    end

  end

  def test_stream_room_messages
    assert_equal stream_room_messages(room_id: 'id'),
                 { msg: 'sub',
                   name: 'stream-room-messages',
                   params: ['id', false] }
  end

  def test_get_room_id
    assert_equal get_room_id(room: 'name'),
                 { msg: 'method',
                   method: 'getRoomIdByNameOrId',
                   params: ['name'] }
  end

  def test_channels_list
    assert_equal channels_list(filter: 'test'),
                 { msg: 'method',
                   method: 'channelsList',
                   params: ['test', 'public', 500, 'name'] }

    assert_equal channels_list(filter: 'test', type: 'private', sort_by: 'msgs', limit: 5),
                 { msg: 'method',
                   method: 'channelsList',
                   params: ['test', 'private', 5, 'msgs'] }

    assert_raises ArgumentNotAllowed do
      channels_list(filter: 'test', type: 'test')
    end

    assert_raises ArgumentNotAllowed do
      channels_list(filter: 'test', sort_by: 'test')
    end
  end

  def test_get_users_of_room
    assert_equal get_users_of_room(room_id: 'id'),
                 { msg: 'method',
                   method: 'getUsersOfRoom',
                   params: ['id', 'false'] }
  end

  def test_read_messages
    assert_equal read_messages,
                 { msg: 'method',
                   method: 'readMessages',
                   params: [] }
  end
end

require_relative '../test_helpers'

require 'json'
require 'rocket-ruby-bot/realtime/api'

class TestRealtimeStream < Minitest::Test
  include RocketRubyBot::Realtime::Stream
  extend RocketRubyBot::Realtime::Stream
  
  def test_stream_notify_all
    assert_equal stream_notify_all(sub: 'roles-change'),
                 { msg: 'sub',
                   name: 'stream-notify-all',
                   params: ['roles-change', false] }

    assert_raises ArgumentNotAllowed do
      stream_notify_all(sub: 'bad_argument')
    end
  end

  def test_stream_notify_logged
    assert_equal stream_notify_logged(sub: 'roles-change'),
                 { msg: 'sub',
                   name: 'stream-notify-logged',
                   params: ['roles-change', false] }

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
                   params: ['id/notification', false] }
    
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
end

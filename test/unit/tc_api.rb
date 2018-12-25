require_relative '../test_helpers'

class TestAPI < MiniTest::Test

  def test_class_for
    klass = RocketRubyBot::API.class_for 'login'
    assert_equal RocketRubyBot::API::Methods, klass

    klass = RocketRubyBot::API.class_for 'stream_notify_all'
    assert_equal RocketRubyBot::API::Streams, klass

    klass = RocketRubyBot::API.class_for 'unknown_method'
    assert_nil klass
  end

  def test_has_methods
    value = RocketRubyBot::API.has_method? 'login'
    assert_equal true, value

    value = RocketRubyBot::API.has_method? 'unknown_method'
    assert_nil value
  end

  def test_params_for
    value = RocketRubyBot::API.params_for 'get_user_roles'
    assert_equal 'getUserRoles', value[:method]
    
    value = RocketRubyBot::API.params_for('unknown_method')
    assert !value
  end
  
end

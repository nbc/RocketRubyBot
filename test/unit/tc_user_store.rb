require_relative '../test_helpers'

require 'rocket-ruby-bot/user_store'

class TestUserStore < Minitest::Test
  def setup
    RocketRubyBot::UserStore.configure do |user_store|
      user_store.test = 'a value'
    end
  end

  def test_configure_as_hashie
    assert_equal 'a value', RocketRubyBot::UserStore.user_store.test
  end

  def test_configure_as_hash
    assert_equal 'a value', RocketRubyBot::UserStore.user_store['test']
  end
end

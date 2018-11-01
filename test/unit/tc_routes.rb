require_relative '../test_helpers'

require 'rocket-ruby-bot/routes'

class RoutesConfig < MiniTest::Test
  def setup
    @class = Class.new
    @class.extend RocketRubyBot::Routes
  end

  def teardown
    @class.routes = []
  end
  
  def test_match
    @class.match(/test/) {}

    assert_instance_of Array, @class.routes
    assert_instance_of Hash, @class.routes.first

    assert_instance_of Proc, @class.routes.first[:block]
    assert_equal /test/i, @class.routes.first[:regexp]
  end

  def test_command
    @class.command('about') {}

    assert_instance_of Array, @class.routes
    assert_instance_of Hash, @class.routes.first

    assert_instance_of Proc, @class.routes.first[:block]
    assert_instance_of Regexp, @class.routes.first[:regexp]
  end
  
end

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

  def test_match_regexp
    @class.match(/test/) {}
    
    match = 'test'.match @class.routes.first[:regexp]
    assert match

    match = 'other_string'.match @class.routes.first[:regexp]
    assert ! match
  end
  
  def test_command
    @class.command('about') {}

    assert_instance_of Array, @class.routes
    assert_instance_of Hash, @class.routes.first

    assert_instance_of Proc, @class.routes.first[:block]
    assert_instance_of Regexp, @class.routes.first[:regexp]
  end

  def test_command_regexp
    @class.command('about') {}

    match = 'about'.match @class.routes.first[:regexp]
    assert ! match

    match = 'mybot about'.match @class.routes.first[:regexp]
    assert match
    assert_equal 'mybot', match[:bot]
    assert_equal 'about', match[:command]
    assert_nil match[:text]

    match = 'mybot about text'.match @class.routes.first[:regexp]
    assert match
    assert_equal 'mybot', match[:bot]
    assert_equal 'about', match[:command]
    assert_equal 'text', match[:text]
  end
end

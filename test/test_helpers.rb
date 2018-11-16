# coding: utf-8

$:.unshift File.expand_path('lib', __dir__)

require 'simplecov'            # These two lines must go first
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
require 'climate_control'

Minitest::Reporters.use!

require 'rocket-ruby-bot'

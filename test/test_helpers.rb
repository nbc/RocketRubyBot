# coding: utf-8
path = File.expand_path(File.join( File.dirname( __FILE__) , "..", "lib"))
$:.unshift path

require 'simplecov'            # These two lines must go first
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
require 'climate_control'

Minitest::Reporters.use!

require 'rocket-ruby-bot'

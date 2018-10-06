$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'rocket-ruby-bot/version'

Gem::Specification.new do |s|
  s.name          = 'rocket-ruby-bot'
  s.version       = RocketRubyBot::VERSION
  s.summary       = "Rocket Ruby Bot library"
  s.description   = 'A very crude and undocumented ruby lib to build RocketChat realtime bots'
  s.authors       = ["Nicolas Chuche"]
  s.email         = 'nicolas@barna.be'
  s.homepage      = 'https://github.com/nbc/rocket-ruby-bot'
  s.licenses      = ['MIT']
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
  s.add_dependency 'hashie', '~> 3.6.0'
  s.add_dependency 'rocketchat', '~> 0'
  s.add_dependency 'eventmachine', '~> 1.2.7'
  s.add_dependency 'json', '~> 2.1.0'
  s.add_dependency 'faye-websocket', '~> 0.10.7'
end

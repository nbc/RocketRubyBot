module RocketRubyBot
  module Config
    extend self

    ATTRS = %i[url user digest user_id token].freeze
    attr_accessor(*ATTRS)

  end
end

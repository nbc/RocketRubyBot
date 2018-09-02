module RocketRubyBot
  module Config
    extend self

    ATTRS = %i[url user user_id token logger].freeze
    attr_accessor(*ATTRS)

  end
end

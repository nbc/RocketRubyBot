require 'hashie'

module RocketRubyBot
  module UserStore
    class << self
      def configure
        block_given? ? yield(user_store) : user_store
      end
    end

    extend self

    def user_store
      @user_store ||= Hashie::Mash.new
    end
  end
end

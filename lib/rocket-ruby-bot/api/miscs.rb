require_relative '../utils/helper'

module RocketRubyBot
  module API
    # implements methods calls from
    # https://rocket.chat/docs/developer-guides/realtime-api/method-calls/
    module Miscs
      def included(base)
        base.extend self
      end
      extend self

      def connect
        { 'msg' => 'connect',
          'version' => '1',
          'support' => ['1'] }
      end

      #= * `send_pong`
      def send_pong
        { msg: 'pong' }
      end
    end
  end
end

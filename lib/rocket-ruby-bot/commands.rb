# coding: utf-8
module RocketRubyBot
  class RocketRubyBot::Commands

    class << self

      attr_accessor :instance

      def hooks
        @instance ||= Hash.new { |h,k| h[k] = [] }
      end

      def command(type, &block)
        hooks[type.to_s] << block
      end

      def message(regexp, &block)
        command :changed do |client, data|
          next unless is_a_message?(data)

          message = data['fields']['args'].first

          # on ne se répond pas à soi-même !
          next if config.user_id == message['u']['_id']

          match = regexp.match(message['msg'])
          if match
            block.call(client, message, match)
          end
        end
      end
      
      def add_hook(type, &block)
        hooks[type.to_s] << block
      end

      def ping
        command :ping do |client, data|
          client.say({msg: 'pong'})
        end
      end
      
      def login(args)
        if args.key?(:user) && args.key?(:digest)
          command :connected do |client, data|
            client.say({msg: 'method',
                        method: 'login',
                        params: [{ user: { username: config.user },
                                   password: { digest: config.digest, algorithm: "sha-256" }}]
                       })
          end
        end
      end

    end
  end
end

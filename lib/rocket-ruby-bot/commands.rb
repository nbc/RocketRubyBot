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

      def add_hook(type, &block)
        p hooks
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

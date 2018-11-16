module RocketRubyBot
  module Config
    extend self

    ATTRS = %i[url user user_id digest logger].freeze
    attr_accessor(*ATTRS)
    attr_writer :websocket_url, :token, :bot_names
    
    def websocket_url
      @websocket_url ||= url
                           .gsub(%r<http(s?)://>, 'ws\1://')
                           .gsub(%r{/$}, '')
                           .concat('/websocket')
    end

    def bot_names
      # FIXME: memorize this
      [user].map(&:downcase)
    end
    
    def token
      @token ||= ENV['ROCKET_API_TOKEN']
    end
  end
end

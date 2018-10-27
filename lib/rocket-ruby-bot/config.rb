module RocketRubyBot
  module Config
    extend self

    ATTRS = %i[url user user_id logger].freeze
    attr_accessor(*ATTRS)
    attr_writer :websocket_url, :token
    
    def websocket_url
      @websocket_url ||= url
                           .gsub(%r<http(s?)://>, 'ws\1://')
                           .gsub(%r{/$}, '')
                           .concat('/websocket')
    end

    def token
      @token ||= ENV['ROCKET_API_TOKEN'] || raise("Missing ENV['ROCKET_API_TOKEN'].")
    end
  end
end

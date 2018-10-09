module RocketRubyBot
  module Config
    extend self

    ATTRS = %i[url user user_id token logger].freeze
    attr_accessor(*ATTRS)
    attr_writer :websocket_url
    
    def websocket_url
      @websocket_url ||= url.
                           gsub(%r<http(s?)://>, 'ws\1://').
                           gsub(%r{/$}, '').
                           concat('/websocket')
    end
    
  end
end

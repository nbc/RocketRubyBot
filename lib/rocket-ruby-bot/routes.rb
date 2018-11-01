module RocketRubyBot
  module Routes

    @@routes = []

    def routes
      @@routes
    end
    
    def match(regexp, &block)
      routes << { regexp: regexp, block: block }
    end

    alias_method :on_message, :match
    
  end
end

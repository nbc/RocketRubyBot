module RocketRubyBot
  module Routes
    extend self

    @@routes = []

    def routes
      @@routes
    end
    
    def match(regexp, &block)
      routes << { regexp: regexp, block: block }
    end

  end
end

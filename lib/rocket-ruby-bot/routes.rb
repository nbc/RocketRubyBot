module RocketRubyBot
  module Routes

    # FIXME : should'nt use class variable
    @@routes = []
    
    def included(base)
      base.extend self
    end
    extend self

    def routes
      @@routes ||= []
    end

    def routes=(arg)
      @@routes = arg
    end
    
    def match(regexp, &block)
      regexp = Regexp.new(regexp.source, Regexp::IGNORECASE)
      routes << { regexp: regexp, block: block }
    end

    def command(*values, &block)
      regexp_text = values.map { |v| v.is_a?(Regexp) ? v.source : Regexp.escape(v) }.join('|')
      regexp = Regexp.new("^(?<bot>\\S+)\\s+(?<command>#{regexp_text})(\\s+(?<text>.*)|)$",
                          Regexp::IGNORECASE | Regexp::MULTILINE)
      match regexp, &block
    end
    
    alias_method :on_message, :match
  end
end

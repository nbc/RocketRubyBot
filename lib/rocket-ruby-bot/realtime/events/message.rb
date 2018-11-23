require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      class User < ::OpenStruct; end

      class MessageAttachment
        attr_reader :text, :translation, :author_name, :title,
                    :author_icon, :message_link, :attachments, :ts
        def initialize(args)
          @text = args.text
          @title = args.title
          @translation = args.translation
          @author_name = args.author_name
          @author_icon = args.author_icon
          @message_link = args.message_link
          @attachments = (args.attachments || []).map { |a| MessageAttachment.new a }
          @ts = args.ts
        end
      end
    end
  end
end

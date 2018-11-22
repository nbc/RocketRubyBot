require 'ostruct'

module RocketRubyBot
  module Realtime
    module Events
      class User < ::OpenStruct; end

      class MessageAttachment
        attr_reader :text, :translation, :author_name,
                      :author_icon, :message_link, :attachments, :ts
        def initialize(args)
          @text = args.text
          @translation = args.translation
          @author_name = args.author_name
          @author_icon = args.author_icon
          @message_link = args.message_link
          @attachments = args.attachments.map { |a| MessageAttachment.new a }
          @ts = args.ts
        end
      end

      class Message
        attr_reader :_id, :rid, :msg, :ts, :u, :urls, :mentions,
                      :channels, :_updatedAd, :attachments, :reactions, :groupable
        def initialize(args)
          @_id = args._id
          @rid = args.rid
          @ts = args.ts
          @msg = args.msg
          @u = User.new args.u
          @urls = args.urls
          @mentions = args.mentions.map { |u| User.new u }
          @channels = args.channels
          @_updatedAt = args._updatedAt
          @editedAt = args.editedAt || ''
          @editedBy = args.editedBy || ''
          @alias = args.alias || ''
          @avatar = args.avatar || ''
          @attachments = args.attachments.map { |a| MessageAttachment.new a }
          @reactions = args.reactions
          @groupable = args.groupable || false
        end
        alias_method :users, :u
        alias_method :id, :_id
        alias_method :room_id, :rid
      end
    end
  end
end

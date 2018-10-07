# coding: utf-8
module RocketRubyBot
  module Realtime
    class Event < Hashie::Mash

      def is_ping?
        return true if _type.eql? :ping
      end
      
      def _type

        if %w[ping connected ready].include? msg
          return msg.to_sym
        end

        if msg.eql? 'changed'
          if collection.eql? 'stream-room-messages'

            if fields.args.first.t.nil?
              # :message : someone sent a message
              return :message
            end
            
            tag = fields.args.first.t
            case tag
            when 'uj'
              # :user_join : a user join a room
              return :user_join
            when 'ul'
              # :user_left : a user left a room
              return :user_left
            when 'au'
              # :added_user : a user was added to room
              return :added_user
            when 'ru'
              # :remove_user : a user was added to room
              return :removed_user
            when /user-(un)?muted/
              # :user_muted : a user was muted
              # :user_unmuted : a user was unmuted
              return tag.gsub(/-/, '_').to_sym
            when /subscription-role-(added|removed)/
              # :subscription-role-removed
              # :subscription-role-added
              return tag.to_sym
            when /room_changed_topic/
              # :room_changed_topic
              return :room_changed_topic
            end
          elsif collection.eql? 'stream-notify-user' # collection
            
            case fields.eventName
            when /notification$/
              # :notification
              return :notification
            when /rooms-changed$/
              # :rooms_changed
              return :rooms_changed
            when /subscriptions-changed$/
              if fields.args.first.eql? 'inserted'
                # :added_to_room
                return :added_to_room
              elsif fields.args.first.eql? 'updated'
                # :room_changed
                return :room_changed
              end
            when /otr$/
              # :otr
              return :otr
            end
          else # collection
            return :unkown
          end # collection

        elsif msg.eql? 'result'

          if result.is_a?(Hash) and !result.token.nil?
            # :authenticated
            return :authenticated
          else
            # :result : information send as result of a command
            return :result
          end

        elsif msg.eql? 'added'

          if collection.eql? 'users'
            # :added_user
            return :added_user
          else
            # :added
            return :added
          end
        end
        # :unknown
        :unknown
      end

      def uid
        self["id"]
      end


      private
      # see https://github.com/intridea/hashie/issues/394
      def log_built_in_message(*); end
    end
  end
end

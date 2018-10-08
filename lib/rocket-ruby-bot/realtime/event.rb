# coding: utf-8
module RocketRubyBot
  module Realtime
    class Event < Hashie::Mash

      def is_ping?
        return true if _type.eql? :ping
      end
      
      def _type
        @type ||= if %w[ping connected ready updated removed failed error].include? msg
          msg.to_sym
        elsif msg.eql? 'changed'
          on_changed
        elsif msg.eql? 'result'
          on_result
        elsif msg.eql? 'added'
          on_added
        else
          :unknown
        end

        if @type == :unknown and @first.nil?
          p [:unknown, self]
          @first = true
        end
        @type
      end

      def uid
        self["id"]
      end

      def on_result
        type = if result.is_a?(Hash) and not result.token.nil?
          # :authenticated
          :authenticated
        else
          # :result : information send as result of a command
          :result
        end
        type
      end

      def on_added
        return case collection
        when 'users'
          # :added_user
          :added_user
        else
          # :added
          :added
        end
      end
      
      def on_changed
        return case collection
        when 'stream-room-messages'
          on_stream_room_messages
        when 'stream-notify-user'
          on_stream_notify_user
        when 'stream-notify-room'
          on_stream_notify_room
        else 
          :unkown
        end 
      end
      
      def on_stream_room_messages
        tag = fields.args.first.t

        return case tag
        when nil
          :message
        when 'uj'
          # :user_join : a user join a room
          :user_join
        when 'ul'
          # :user_left : a user left a room
          :user_left
        when 'au'
          # :added_user : a user was added to room
          :added_user
        when 'ru'
          # :remove_user : a user was added to room
          :removed_user
        when /user-(un)?muted/
          # :user_muted : a user was muted
          # :user_unmuted : a user was unmuted
          tag.gsub(/-/, '_').to_sym
        when /subscription-role-(added|removed)/
          # :subscription-role-removed
          # :subscription-role-added
          tag.to_sym
        when /room_changed_topic/
          # :room_changed_topic
          :room_changed_topic
        else
          :unknown
        end

      end

      def on_stream_notify_user
        return case fields.eventName
        when /notification$/
          # :notification
          :notification
        when /rooms-changed$/
          # :rooms_changed
          :rooms_changed
        when /subscriptions-changed$/

          case fields.args.first
          when 'inserted'
            # :added_to_room
            :new_message
          when 'updated'
            # :added_to_room
            :added_to_room
          else
            :unknown
          end
          
        when /otr$/
          # :otr
          :otr
        else
          :unkown
        end
      end

      def on_stream_notify_room
        
      end
      
      private
      # see https://github.com/intridea/hashie/issues/394
      def log_built_in_message(*); end
    end
  end
end

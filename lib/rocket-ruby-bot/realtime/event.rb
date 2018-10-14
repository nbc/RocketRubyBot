require 'hashie'

#= # events

#= list of events
#= 

# coding: utf-8
module RocketRubyBot
  module Realtime
    class Event < Hashie::Mash

      def is_ping?
        return true if _type.eql? :ping
      end
      
      def _type
        @type ||= if %w[ping connected ready updated removed failed error].include? msg
          #= * `:connected`
          #=   return on server connection
          #= * `:ready`
          #=   returned on subscription (sub_stream_room_messages...)
          #=   https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/
          #= * `:updated`
          #= * `:removed`
          #= * `:failed`
          #= * `:error`
          #= * `:ping` : ping from server, automatically handled by the ping hook
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

        # log the unknown event if first see
        if @type == :unknown and @already_seen.nil?
          p [:unknown, self.to_json]
          @already_seen = false
        end
        @type
      end

      def uid
        self["id"]
      end

      #= 
      #= ## `results` events
      #= 
      def on_result
        type = if result.is_a?(Hash) and not result.token.nil?
          #= * `:authenticated`
          #=   returned on successful login
          #=   https://rocket.chat/docs/developer-guides/realtime-api/method-calls/login/
          #=   `:authenticated`
          #= 
          :authenticated
        else
          #= * `:result`
          #=   event returned for all requests except authentication
          #=   example : https://rocket.chat/docs/developer-guides/realtime-api/method-calls/get-user-roles/
          #=   ...
          #= 
          :result
        end
        type
      end

      #= 
      #= ## `added` events
      #= 
      def on_added
        return case collection
        when 'users'
          #= 
          #= * `:added_user`
          #= 
          :added_user
        else
          #= * `:added`
          #= 
          :added
        end
      end

      #= ## `changed` events
      #=
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
      
      #= ### `stream_notify_room` events
      #=
      def on_stream_room_messages
        tag = fields.args.first.t

        return case tag
        when nil
          :message
        when 'uj'
          #= * `:user_join` : a user join a room
          :user_join
        when 'ul'
          #= * `:user_left` : a user left a room
          :user_left
        when 'au'
          #= * `:added_user` : a user was added to room
          :added_user
        when 'ru'
          #= * `:remove_user` : a user was removed from room
          :removed_user
        when /user-(un)?muted/
          #= * `:user_muted`
          #= * `:user_unmuted`
          tag.gsub(/-/, '_').to_sym
        when /subscription-role-(added|removed)/
          #= * `:subscription-role-removed`
          #= * `:subscription-role-added`
          tag.to_sym
        when /room_changed_topic/
          #= * `:room_changed_topic`
          :room_changed_topic
        else
          :unknown
        end

      end

      #= ### `stream_notify_user` events
      def on_stream_notify_user
        return case fields.eventName
        when /notification$/
          #= * `:notification`
          :notification
        when /rooms-changed$/
          #= * `:rooms_changed`
          :rooms_changed
        when /subscriptions-changed$/
          case fields.args.first
          when 'inserted'
            #= * `:new_message`
            :new_message
          when 'updated'
            #= * `:added_to_room`
            :added_to_room
          else
            :unknown
          end
        when /otr$/
          #= * `:otr`
          :otr
        else
          :unkown
        end
      end

      #= ## `stream_notify_room` events
      def on_stream_notify_room
        
        return case fields.eventName
        when 'typing'
          #= * `:typing`
          :typing
        when 'deleteMessage'
          #= `:delete_message`
          :delete_message
        else
          :unknown
        end
      end
      
      private
      # see https://github.com/intridea/hashie/issues/394
      def log_built_in_message(*); end
    end
  end
end

#= 
#= # Sources
#= 
#= For information on events, you can
#= https://bitbucket.org/EionRobb/purple-rocketchat
#= https://github.com/mathieui/unha2/blob/master/docs/methods.rst

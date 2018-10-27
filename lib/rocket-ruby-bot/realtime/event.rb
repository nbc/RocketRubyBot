# coding: utf-8

require 'hashie'

#= # events

#= list of events
#=

# coding: utf-8
module RocketRubyBot
  module Realtime
    # parse data returned by RC
    class Event < Hashie::Mash

      def ping?
        return true if _type.eql? :ping
      end

      BASIC_EVENTS = %w[ping connected ready updated removed failed error nosub].freeze
      def _type
        @type ||= if BASIC_EVENTS.include? self['msg']
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
          self['msg'].to_sym
        elsif self['msg'].eql? 'changed'
          on_changed
        elsif self['msg'].eql? 'result'
          on_result
        elsif self['msg'].eql? 'added'
          on_added
        else
          :unknown
        end

        # log the unknown event if first see
        if @type == :unknown && @already_seen.nil?
          p [:unknown, to_json]
          @already_seen = false
        end
        @type
      end

      def result_id
        ret = if _type.eql? :ready
          self['subs'].first
        else
          self['id']
        end
        ret
      end

      #=
      #= ## `results` events
      #=
      def on_result
        type = if self['result'].is_a?(Hash) && !self['result']['token'].nil?
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
      # {"msg":"added","collection":"users","id":"hZKg86uJavE6jYLya",
      #  "fields":{"emails":[{"address":"eion@robbmob.com","verified":true}],"username":"eionrobb"}}
      # {"msg":"added","collection":"users","id":"M6m6odi9ufFJtFzZ3","fields":{"status":"online","username":"ali-14","utcOffset":3.5}}

      def on_added
        return case self['collection']
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
      # FIXME : event found in librocketchat.c :
      # {"msg":"changed","collection":"users","id":"123","fields":{"active":true,"name":"John Doe","type":"user"}}
      def on_changed
        return case self['collection']
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
      
      #= ### `stream-room-messages` events
      #=
      #= https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-room-messages/
      #=
      def on_stream_room_messages
        tag = self['fields']['args'].first.t

        return case tag
        when nil
          #= * `:message` : new message, event on message (reactions...)
          #
          # {"msg":"changed","collection":"stream-room-messages","id":"id",
          #  "fields":{"eventName":"GENERAL",
          #  "args":[{"_id":"ei3gxB5SqWJHoGDkm","rid":"GENERAL","msg":"Bonjour, ",
          #           "ts":{"$date":1540063554370},"alias":"Francois",
          #           "u":{"_id":"9fjarYAeJtEBo2quC","username":"f.g",
          #           "name":"Francois"},"mentions":[],"channels":[],"_updatedAt":{"$date":1540284243523},
          #           "reactions":{":hand_splayed_tone3:":{"usernames":["s.c","l.r",
          #                                                             "m.c","k.d"]},
          #                        ":wave:":{"usernames":["isabelle"]}}}]}}

          :message
        when 'uj'
          #= * `:user_join` : user join room
          :user_join
        when 'ul'
          #= * `:user_left` : user left room
          :user_left
        when 'au'
          #= * `:added_user` : user added to room
          :added_user
        when 'ru'
          #= * `:remove_user` : user removed from room
          :removed_user
        when /user-(un)?muted/
          #= * `:user_muted`
          #= * `:user_unmuted`
          tag.tr('-', '_').to_sym
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

      #= ### `stream-notify-user` events
      #=
      #= https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-user/
      #=
      def on_stream_notify_user
        return case self['fields']['eventName']
        when /notification$/
          #= * `:notification`
          :notification
        when /rooms-changed$/
          #= * `:rooms_changed`
          # 
          # New chat started
	  # {"msg":"changed","collection":"stream-notify-user","id":"id","fields":{"eventName":"hZKg86uJavE6jYLya/rooms-changed",
          #  "args":["inserted",{"_id":"JoxbibGnXizRb4ef4hZKg86uJavE6jYLya","t":"d"}]}}
          #
	  # {"msg":"changed","collection":"stream-notify-user","id":"id","fields":{"eventName":"hZKg86uJavE6jYLya/rooms-changed",
          #  "args":["inserted",{"_id":"GENERAL","name":"general","t":"c","topic":"Community support in [#support](https://demo.rocket.chat/channel/support).
          #      Developers in [#dev](https://demo.rocket.chat/channel/dev)","muted":["daly","kkloggg","staci.holmes.segarra"],
          #      "jitsiTimeout":{"$date":1477687206856},"default":true}]}}
          #
	  # {"msg":"changed","collection":"stream-notify-user","id":"id","fields":{"eventName":"hZKg86uJavE6jYLya/rooms-changed",
          #   "args":["updated",{"_id":"ocwXv7EvCJ69d3AdG","name":"eiontestchat","t":"p","u":{"_id":null,"username":null},"topic":"ham salad","ro":false}]}}


          :rooms_changed
        when /subscriptions-changed$/
          case fields.args.first
          when 'inserted'
            #= * `:inserted` user added to a new room
            :inserted
          when 'updated'
            #= * `:updated` : something change in room, topic, announcement...
            :updated
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

      #= ## `stream-notify-room` events
      def on_stream_notify_room
        
        return case self['fields']['eventName']
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

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
        return true if type.eql? :ping
      end

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


      # FIXME: should'nt be here cause it pollute the real event
      def yield_unless_seen
        return if @_already_seen

        yield
        @_already_seen = true
      end
      
      BASIC_EVENTS = %w[ping connected ready updated removed failed error nosub].freeze
      def type
        @type ||=
          if BASIC_EVENTS.include? self['msg']
            self['msg'].to_sym
          elsif self['msg'].eql? 'changed'
            on_changed
          elsif self['msg'].eql? 'result'
            on_result
          elsif self['msg'].eql? 'added'
            on_added
          else
            yield_unless_seen { p [:unknown, to_json] }
            :unknown
          end
        @type
      end

      def result_id
        return self['subs'].first if type.eql? :ready
        self['id']
      end

      #=
      #= ## `results` events
      #=
      #= * `:authenticated`
      #=   returned on successful login
      #=   https://rocket.chat/docs/developer-guides/realtime-api/method-calls/login/
      #=   `:authenticated`
      #=
      #= * `:result`
      #=   event returned for all requests except authentication
      #=   example : https://rocket.chat/docs/developer-guides/realtime-api/method-calls/get-user-roles/
      #=   ...
      #=

      def has_token
        self['result'].is_a?(Hash) && self['result'].key?('token')
      end
      
      def on_result
        return :authenticated if has_token
        :result
      end

      #=
      #= ## `added` events
      #=
      # {"msg":"added","collection":"users","id":"hZKg86uJavE6jYLya",
      #  "fields":{"emails":[{"address":"eion@robbmob.com","verified":true}],"username":"eionrobb"}}
      # {"msg":"added","collection":"users","id":"M6m6odi9ufFJtFzZ3","fields":{"status":"online","username":"ali-14","utcOffset":3.5}}
      #=
      #= * `:added_user`
      #=
      #= * `:added`
      #=

      def on_added
        return :added_user if self['collection'] == 'users'
        :added
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
      #= * `:user_join` : user join room
      #= * `:user_left` : user left room
      #= * `:added_user` : user added to room
      #= * `:remove_user` : user removed from room
      #= * `:user_muted`
      #= * `:user_unmuted`
      #= * `:subscription_role_removed`
      #= * `:subscription_role_added`
      #= * `:room_changed_topic`

      STREAM_ROOM_MESSAGE =
        { 'uj' => :user_join, 
          'ul' => :user_left,
          'au' => :user_added,
          'user-muted' => :user_muted,
          'user-umuted' => :user_unmuted,
          'subscription-role-added' => :subscription_role_added,
          'subscription-role-removed' => :subscription_role_removed,
          'room-changed-topic' => :room_changed_topic }
      
      def on_stream_room_messages
        message = self['fields']['args'].first
        return :message unless message.key? 't'
        return STREAM_ROOM_MESSAGE[message.t] if STREAM_ROOM_MESSAGE.key? message.t
        :unknown
      end

      #= ### `stream-notify-user` events
      #=
      #= https://rocket.chat/docs/developer-guides/realtime-api/subscriptions/stream-notify-user/
      #=
      #= * `:notification`
      #= * `:rooms_changed`
      #= * `:self_inserted` : self added to room
      #= * `:self_removed` : self removed from room
      #= * `:self_updated` : self updated (new role, owner...)
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
      #= * `:inserted` user added to a new room
      #= * `:updated` : something change in room, topic, announcement...
      #= * `:otr`

      STREAM_NOTIFY_USER =
        { 'notification' => :notification,
          'rooms-changed' => :rooms_changed,
          'otr' => :otr }
      
      def on_stream_notify_user
        event = self['fields']['eventName'].split('/').last
        return STREAM_NOTIFY_USER[event] if STREAM_NOTIFY_USER.key? event

        action = self['fields']['args'][0]
        if event == 'subscriptions-changed' and action
          return "self_#{action}".to_sym
        end 
        
        :unknown
      end

      #= ## `stream-notify-room` events
      #= * `:typing`
      #= * `:delete_message`

      STREAM_NOTIFY_ROOM =
        { 'typing' => :typing,
          'deleteMessage' => :delete_message }
      
      def on_stream_notify_room
        event =  self['fields']['eventName'].split('/').last
        return STREAM_NOTIFY_ROOM[event] if STREAM_NOTIFY_ROOM.key? event
        :unknown
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

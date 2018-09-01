module RocketRubyBot
  class Message < Hashie::Mash
    def _type

      if %w[ping connected ready result added].include? msg
        return msg.to_sym
      end

      def _id
        self["id"]
      end
      
      if msg == 'changed'
        if collection == 'stream-room-messages'
          return :message if fields.args.first.t.nil?
          
          tag = fields.args.first.t
          case tag
          when 'uj'
            return :user_join
          when 'ul'
            return :user_left
          when 'au'
            return :added_user
          when 'ru'
            return :removed_user
          when /user-(un)?muted/
            return tag.to_sym
          when /subscription-role-(added|removed)/
            return tag.to_sym
          when /room_changed_topic/
            return :room_changed_topic
          end
        else collection == 'stream-notify-user'
          
          case fields.eventName
          when /notification$/
            return :notification
          when /rooms-changed$/
            return :rooms_changed
          when /subscriptions-changed$/
            if fields.args.first == 'inserted'
              return :added_to_room
            elsif fields.args.first == 'updated'
              return :room_changed
            end
          when /otr$/
            return :otr
          end

        end # collection
      end
      :unknown
    end

    private
    # see https://github.com/intridea/hashie/issues/394
    def log_built_in_message(*); end
  end
end

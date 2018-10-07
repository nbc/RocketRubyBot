# coding: utf-8
module RocketRubyBot
  class Message < Hashie::Mash

    def is_ping?
      return true if _type.eql? "ping"
    end
    
    def _type

      if %w[ping connected ready].include? msg
        return msg.to_sym
      end

      if msg.eql? 'changed'
        if collection.eql? 'stream-room-messages'
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
            return tag.gsub(/-/, '_').to_sym
          when /subscription-role-(added|removed)/
            return tag.to_sym
          when /room_changed_topic/
            return :room_changed_topic
          end
        else collection.eql? 'stream-notify-user'
          
          case fields.eventName
          when /notification$/
            return :notification
          when /rooms-changed$/
            return :rooms_changed
          when /subscriptions-changed$/
            if fields.args.first.eql? 'inserted'
              return :added_to_room
            elsif fields.args.first.eql? 'updated'
              return :room_changed
            end
          when /otr$/
            return :otr
          end

        end # collection
      elsif msg.eql? 'result'

        if result.is_a?(Hash) and !result.token.nil?
          return :authenticated
        else
          return :result
        end

      elsif msg.eql? 'added'

        if collection.eql? 'users'
          return :added_user
        else
          return :added
        end
      end
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

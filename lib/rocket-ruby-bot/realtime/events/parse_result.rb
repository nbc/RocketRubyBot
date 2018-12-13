module RocketRubyBot
  module Realtime
    module Events
      module ParseResult
        def self.login(params)
          if params.respond_to? :result
            result = params.result
            Result.new id: params.id,
                       value: OpenStruct.new(token: result.token, user_id: result.id, expires: result.tokenExpires)
          elsif params.respond_to? :error
            Result.new id: params.id,
                       value: OpenStruct.new(error: params.error.message)
          end
        end

        def self.get_room_id(params)
          Result.new id: params.id, value: OpenStruct.new(room_id: params.result)
        end

        def self.get_user_roles(params)
          roles = params.result.map do |l|
            OpenStruct.new user_id: l._id,
                           roles: l.roles,
                           username: l.username
          end
          Result.new id: params.id, value: roles
        end

      end
    end
  end
end

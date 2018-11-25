# coding: utf-8

require 'ostruct'

# class to handle voting system
class Vote
  attr_reader :choices, :user, :voters, :room_id

  class << self
    attr_accessor :bot_name
    
    def votes
      @votes ||= {}
    end

    def create_vote(user, room_id, args)
      return %(désolé, un vote est déjà en cours dans ce canal) if votes[room_id]
      
      votes[room_id] = Vote.new(user, room_id, args)
      votes[room_id].message
    end

    def vote(room_id)
      return NullVote.new unless votes.key?(room_id)
      
      votes[room_id]
    end

    def close(user, room_id)
      return 'pas de vote en cours' unless votes.key?(room_id) && 
                                           (user == votes[room_id].user)

      msg = votes[room_id].result
      votes.delete room_id
      msg
    end
  end

  def initialize(user, room_id, str)
    @user = user
    @choices = {}
    @voters = {}
    @room_id = room_id
    
    choices = str.scan(/"(.*?)"/).flatten
    choices.each_with_index do |c, i|
      index = i + 1
      @choices[index] = OpenStruct.new(text: c, id: index)
    end
  end
  alias_method :rid, :room_id

  def message
    msg = "#{user} vous propose ce vote :\n"
    msg << propositions
  end

  def propositions
    msg = choices.inject('') do |c, (_k, v)|
      c + "vote #{v.id}: #{v.text}\n"
    end
    msg << message_to_vote
  end

  def voice(user, msg)
    re = msg.match(/vote\s+(\d+)/)
    return message_to_vote unless re
    
    choice = re[1].to_i
    
    if choices.key? choice
      voters[user] = choice
      return %(@#{user} a voté pour "#{choice}")
    end
    
    msg = %(Hey @#{user}, "#{vote}" n'existe pas, vous pouvez votez pour :\n)
    msg << propositions
  end

  def result
    result = Hash.new(0)
    @voters.values.each do |v|
      result[v] += 1
    end
    
    msg = "Le résultat du vote est :\n"
    result.sort_by { |_k, v| v }.reverse_each do |k, v|
      msg << "#{v}: #{@choices[k].text}\n"
    end
    msg
  end

  def message_to_vote
    %(pour voter, envoyer "#{Vote.bot_name} vote <numero>"\n)
  end
end

class NullVote
  def voice(*args)
    'pas de vote en cours'
  end
  alias_method :propositions, :voice
  alias_method :message, :voice
  alias_method :close, :voice
end

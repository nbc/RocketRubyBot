# coding: utf-8

require 'ostruct'

# class to handle voting system
class Vote
  attr_reader :choices, :user, :voters, :room_id

  class << self
    def create_vote(user, room_id, args)
      return %(désolé, un vote est déjà en cours) if @vote

      @vote ||= {}
      
      @vote[room_id] = Vote.new(user, room_id, args)
      @vote[room_id].message
    end

    def vote(room_id)
      return unless @vote && @vote.key?(room_id)
      
      @vote[room_id]
    end
    
    def close(user, room_id)
      return unless @vote.key?(room_id) && 
                    (user == @vote[room_id].user)

      msg = @vote[room_id].result
      @vote[room_id] = nil
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
      c + "#{user} vote #{v.id}: #{v.text}\n"
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
    %(pour voter, envoyer "vote <numero>"\n)
  end
end

__END__

puts Vote.create_vote('Nicolas Chuche',
                      '"un premier choix", "un second choix", "un troisieme choix"')

puts Vote.vote.voice('is', 1)
puts Vote.vote.voice('nc', 1)
puts Vote.vote.voice('nc', 2)
puts Vote.vote.voice('al', 2)
puts Vote.vote.voice('ae', 2)
puts Vote.vote.voice('ab', 4)

puts Vote.vote.result

puts Vote.close

# coding: utf-8

require_relative '../test_helpers'

require_relative '../../examples/simple_vote/simple_vote.rb'

class TestSimpleVote < Minitest::Test

  def setup
    SimpleVote.bot_name = 'mybot'
  end

  def test_null_vote
    null = SimpleVote::NullVote.new

    %i[vote_for propositions message close].each do |method|
      assert_respond_to null, method
      assert_match(/pas de/, null.send(method))
    end
  end

  def test_new_vote
    vote = SimpleVote::Vote.new('nc', 'room', '"1", "2", "3"')

    assert_equal 3, vote.choices.length
    assert_equal 'room', vote.room_id
    assert_equal 'nc', vote.user
  end

  def test_message
    vote = SimpleVote::Vote.new('nc', 'room', '"1", "2", "3"')
    msg = vote.message
    assert_match(/vous propose/, msg)
    assert_match(/vote 1: 1/, msg)
    assert_match(/vote 2: 2/, msg)
    assert_match(/vote 3: 3/, msg)
  end
  
  def test_vote
    vote = SimpleVote::Vote.new('nc', 'room', '"1", "2", "3"')
    vote.vote_for('nc', 'mybot vote 1')

    assert vote.voters.key? 'nc'
  end

  def test_result
    vote = SimpleVote::Vote.new('nc', 'room', '"1", "2", "3"')
    vote.vote_for('nc', 'mybot vote 1')
    vote.vote_for('ab', 'mybot vote 1')
    vote.vote_for('ed', 'mybot vote 2')

    assert_match(/2: 1/, vote.result)
  end

  def test_no_such_vote
    vote = SimpleVote::Vote.new('nc', 'room', '"1", "2", "3"')
    msg = vote.vote_for('nc', 'mybot vote 4')

    assert_match(/existe pas/, msg)
  end

  def test_create_vote
    msg = SimpleVote.create_vote('nc', 'room', '"1", "2", "3"')
    assert_match(/vous propose/, msg)
    assert_equal 'room', SimpleVote.find_vote('room').room_id
  end

  def test_create_vote_while_one_exists
    SimpleVote.create_vote('nc', 'room', '"1", "2", "3"')
    msg = SimpleVote.create_vote('nc', 'room', '"1", "2", "3"')
    assert_match(/en cours/, msg)
  end

  def test_when_no_vote
    msg = SimpleVote.close('nc', 'room')
    assert_match(/en cours/, msg)
  end

  def test_close_vote
    SimpleVote.create_vote('nc', 'room', '"1", "2", "3"')
    msg = SimpleVote.close('ab', 'room')

    assert_match(/seul/, msg)

    msg = SimpleVote.close('nc', 'room')
    assert_match(/vote est/, msg)
  end

  def test_vote_after_closing
    SimpleVote.create_vote('nc', 'room', '"1", "2", "3"')
    SimpleVote.close('nc', 'room')

    vote = SimpleVote.find_vote('room')
    assert_match(/pas de vote/, vote.vote_for('nc', 'mybot vote 1'))
  end
  
  def teardown
    SimpleVote.votes = {}
  end
  
end

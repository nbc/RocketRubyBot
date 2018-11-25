# coding: utf-8

require_relative '../test_helpers'

require_relative '../../examples/simple_vote/vote.rb'

class TestSimpleVote < Minitest::Test
  def test_null_vote
    null = Vote::NullVote.new

    %i[voice propositions message close].each do |method|
      assert_respond_to null, method
      assert_match(/pas de/, null.send(method))
    end
  end

  def test_new_vote
    vote = Vote::Vote.new('nc', 'room', '"1", "2", "3"')

    assert_equal 3, vote.choices.length
    assert_equal 'room', vote.room_id
    assert_equal 'nc', vote.user
  end

  def test_message
    vote = Vote::Vote.new('nc', 'room', '"1", "2", "3"')
    msg = vote.message
    assert_match(/vous propose/, msg)
    assert_match(/vote 1: 1/, msg)
    assert_match(/vote 3: 3/, msg)
  end
  
  def test_vote
    vote = Vote::Vote.new('nc', 'room', '"1", "2", "3"')
    vote.voice('nc', 'mybot vote 1')

    assert vote.voters.key? 'nc'
  end

  def test_result
    vote = Vote::Vote.new('nc', 'room', '"1", "2", "3"')
    vote.voice('nc', 'mybot vote 1')
    vote.voice('ab', 'mybot vote 1')
    vote.voice('ed', 'mybot vote 2')

    assert_match(/2: 1/, vote.result)
  end

  def test_no_such_vote
    vote = Vote::Vote.new('nc', 'room', '"1", "2", "3"')
    msg = vote.voice('nc', 'mybot vote 4')

    assert_match(/existe pas/, msg)
  end

  def test_create_vote
    msg = Vote.create_vote('nc', 'room', '"1", "2", "3"')
    assert_match(/vous propose/, msg)
    assert_equal 'room', Vote.vote('room').room_id
  end

  def test_create_vote_while_one_exists
    Vote.create_vote('nc', 'room', '"1", "2", "3"')
    msg = Vote.create_vote('nc', 'room', '"1", "2", "3"')
    assert_match(/en cours/, msg)
  end

  def test_when_no_vote
    msg = Vote.close('nc', 'room')
    assert_match(/en cours/, msg)
  end

  def test_close_vote
    Vote.create_vote('nc', 'room', '"1", "2", "3"')
    msg = Vote.close('ab', 'room')

    assert_match(/seul/, msg)

    msg = Vote.close('nc', 'room')
    assert_match(/vote est/, msg)
  end

  def test_vote_after_closing
    Vote.create_vote('nc', 'room', '"1", "2", "3"')
    Vote.close('nc', 'room')

    vote = Vote.vote('room')
    assert_match(/pas de vote/, vote.voice('nc', 'mybot vote 1'))
  end
  
  def teardown
    Vote.votes = {}
  end
  
end

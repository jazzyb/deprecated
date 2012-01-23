require 'test/unit'
require 'forchess'

class AITest < Test::Unit::TestCase
  def test_moves
    board = Forchess::Board.new 'test/boards/ai1.txt'
    ai = Forchess::AI.new board
    move = ai.next_move(:first, 4)
    assert_equal [[2,7],[2,0]], move.move
    board.move move
    move = ai.next_move(:fourth, 4)
    assert_equal [[0,7],[2,6]], move.move
    board.move move
    move = ai.next_move(:first, 4)
    assert_equal [[2,0],[7,0]], move.move
  end

  def test_removes
    board = Forchess::Board.new 'test/boards/ai2.txt'
    ai = Forchess::AI.new board
    move = ai.next_move(:first, 6)
    assert_equal :knight, move.piece

    board = Forchess::Board.new 'test/boards/ai3.txt'
    ai = Forchess::AI.new board
    move = ai.next_move(:first, 4)
    assert_equal :pawn, move.piece
  end
end

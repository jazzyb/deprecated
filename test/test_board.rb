require 'test/unit'
require 'forchess'

class BoardTest < Test::Unit::TestCase
  def test_setup_and_placement
    _setup_board
    _check_errors
    _get_pieces
    _remove_pieces
    _set_pieces
  end

=begin TODO
  def test_moves
    @board = Forchess::Board.new 'test/boards/board2.txt'
  end
=end

  private

  def _setup_board
    @board = Forchess::Board.new
    assert_raise(RuntimeError) { @board.setup 'non-existent-file.txt' }
    assert_nothing_raised(RuntimeError) do
      player = @board.setup 'test/boards/board1.txt'
      assert_equal :second, player
    end
  end

  def _check_errors
    assert_raise(RuntimeError) { @board[-1][2] }
    assert_raise(RuntimeError) { @board[7][8] }
    assert_raise(RuntimeError) { @board[1]['foo'] }
    assert_raise(RuntimeError) { @board[1]['x'] }
    assert_raise(Forchess::Assertion) { @board[:foo] }
  end

  def _get_pieces
    assert_nothing_raised(RuntimeError, Forchess::Assertion) do
      assert_equal :first, @board.get_piece([4, 4])[:player]
      assert_equal :king, @board.get_piece([4, 4])[:piece]
      assert_equal :first, @board['a']['3'][:player]
      assert_equal :bishop, @board['a']['3'][:piece]
      assert_equal :second, @board[2][1][:player]
      assert_equal :pawn, @board[2][1][:piece]
      assert_equal :second, @board[7]['4'][:player]
      assert_equal :king, @board[7]['4'][:piece]
      assert_equal :third, @board['d'][7][:player]
      assert_equal :knight, @board['d'][7][:piece]
      assert_equal :fourth, @board['b']['6'][:player]
      assert_equal :rook, @board['b']['6'][:piece]
      assert_equal :none, @board['e']['3'][:player]
      assert_equal :none, @board['e']['3'][:piece]
    end
  end

  def _remove_pieces
    ret = @board.remove_piece([7, 3])
    assert_equal :second, ret[:player]
    assert_equal :king, ret[:piece]
    assert_equal :none, @board.get_piece([7, 3])[:player]
    assert_equal :none, @board.get_piece([7, 3])[:piece]
    @board['a']['3'] = Hash.new(:none)
    assert_equal :none, @board.get_piece([0, 2])[:player]
    assert_equal :none, @board.get_piece([0, 2])[:piece]
  end

  def _set_pieces
    @board[0][0] = {:player => :third, :piece => :rook}
    assert_equal :third, @board.get_piece([0, 0])[:player]
    assert_equal :rook, @board.get_piece([0, 0])[:piece]
  end
end

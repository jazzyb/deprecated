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

  def test_moves
    _get_moves
    _create_move
    _move_piece
    _remove_piece
  end

  # stolen from test_forchess_checkmate in ext/libforchess/test/check_check.c
  def test_check_status
    @board = Forchess::Board.new 'test/boards/board2.txt'
    assert_equal(:none, @board.check_status(:first))
    assert_equal(:none, @board.check_status(:second))
    assert_equal(:none, @board.check_status(:third))
    assert_equal(:none, @board.check_status(:fourth))
    @board = Forchess::Board.new 'test/boards/board3.txt'
    assert(@board.checkmate? :first)
    assert(@board.check? :second)
    @board['d']['4'] = {:player => :first, :piece => :bishop}
    assert(@board.check? :first)
    assert(@board.checkmate? :second)
  end

  # tests stolen from ext/libforchess/test/check_board.c
  def test_removes
    # from test_forchess_board_get_valid_removes1
    @board = Forchess::Board.new 'test/boards/board4.txt'
    moves = @board.get_moves :first
    assert_equal 1, moves.size
    assert_equal :first, moves[0].player
    assert_equal :king, moves[0].piece
    assert_equal [[0,0]], moves[0].move

    # from test_forchess_board_get_valid_removes2
    @board = Forchess::Board.new 'test/boards/board5.txt'
    moves = @board.get_moves :first
    assert_equal 1, moves.size
    assert_equal :first, moves[0].player
    assert_equal :pawn, moves[0].piece
    assert_equal [[1,1]], moves[0].move

    # from test_forchess_board_get_valid_removes3
    @board = Forchess::Board.new 'test/boards/board6.txt'
    moves = @board.get_moves :first
    list = moves.map { |m| m.move }
    assert_equal 3, moves.size
    [ [[0,1]], [[1,1]], [[1,0]] ].each do |result|
      assert_not_nil(list.find result)
    end
  end

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

  def _get_moves
    result_set = [ [[0,3],[0,4]],
                   [[1,3],[1,4]],
                   [[2,3],[2,4]],
                   [[3,3],[3,4]],
                   [[3,3],[4,3]],
                   [[3,2],[4,2]],
                   [[3,1],[4,1]],
                   [[3,0],[4,0]],
                   [[0,2],[1,4]],
                   [[2,1],[4,0]],
                   [[2,1],[4,2]],
                   [[1,1],[2,2]] ]
    @board = Forchess::Board.new 'test/boards/board2.txt'
    moves = @board.get_moves(0)
    list = moves.map { |m| m.move }
    assert_equal 12, moves.size
    result_set.each do |result|
      assert_not_nil(list.find result)
    end
  end

  def _create_move
    coords = [[0,3],[1,7]]
    @move = @board.create_move coords
    assert_equal :first, @move.player
    assert_equal :pawn, @move.piece
    assert_equal :second, @move.opp_player
    assert_equal :rook, @move.opp_piece
    assert_equal coords, @move.move
  end

  def _move_piece
    assert_raise(RuntimeError) { @board.move @move }
    @move.promotion = :queen
    assert_nothing_raised(RuntimeError) { @board.move @move }
    assert_equal :first, @board['b']['8'][:player]
    assert_equal :queen, @board['b']['8'][:piece]
    assert_equal :none, @board['a']['4'][:player]
    assert_equal :none, @board['a']['4'][:piece]
  end

  def _remove_piece
    coords = [[7,7]]
    rm = @board.create_move coords
    assert_equal :third, rm.player
    assert_equal :king, rm.piece
    assert_equal :none, rm.opp_player
    assert_equal :none, rm.opp_piece
    assert_equal coords, rm.move
    @board.move rm
    assert_equal :none, @board['h']['8'][:player]
    assert_equal :none, @board['h']['8'][:piece]
  end
end

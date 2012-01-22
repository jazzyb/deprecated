require 'test/unit'
require 'forchess'

class MoveListTest < Test::Unit::TestCase
  def setup
    @board = Forchess::Board.new('test/boards/move_list.txt')
    @move_list = Forchess::MoveList.new @board
    Forchess.fc_board_get_moves(@board.to_ptr, @move_list.to_ptr, :first)
  end

  def test_length
    assert_equal 12, @move_list.length
    assert_equal 12, @move_list.size
  end

  def test_index
    assert_equal @move_list.max, @move_list[0]
    assert_equal @move_list.min, @move_list[-1]
    assert_equal nil, @move_list[100]
    assert_equal nil, @move_list[-100]
  end

  def test_each
    i = 0
    @move_list.each do |move|
      assert(move == @move_list[i])
      i += 1
    end
  end

  def test_insert
    # TODO write fake move objects for move and move_list tests
    p = FFI::MemoryPointer.new(Forchess::Move::ManagedMoveStruct, 1)
    p = FFI::Pointer.new p
    ms = Forchess::Move::ManagedMoveStruct.new p
    ms[:player] = :first
    ms[:piece] = :king
    ms[:move] = 513
    assert_equal 12, @move_list.length
    move = Forchess::Move.new p
    move.value = -3
    @move_list << move
    move.value = 100000
    @move_list << move
    assert_equal 100000, @move_list[0].value
    assert_equal -3, @move_list[-1].value
    assert_equal 14, @move_list.length
  end

  def test_merge
    other_mlist = @board.get_moves(:second)
    new_mlist = @move_list + other_mlist
    assert_equal @move_list.length + other_mlist.length, new_mlist.length
    @move_list.each do |move|
      assert_not_nil new_mlist.find(move)
    end
    other_mlist.each do |move|
      assert_not_nil new_mlist.find(move)
    end
  end

  def test_delete
    assert_equal 12, @move_list.length
    move = @move_list[3]
    @move_list.delete move
    assert_equal 11, @move_list.length
    @move_list.each do |m|
      assert_not_equal m, move
    end
  end
end

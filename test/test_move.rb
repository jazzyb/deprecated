require 'test/unit'
require 'forchess'

class MoveTest < Test::Unit::TestCase
  def test_coords
    move = Forchess::Move.new nil, :coords
    assert_equal :coords, move.move
  end

  def test_promotion
    move = Forchess::Move.new
    assert_not_equal :queen, move.promotion
    move.promotion = :queen
    assert_equal :queen, move.promotion
  end

  def test_comparison
    p1 = FFI::MemoryPointer.new(Forchess::Move::ManagedMoveStruct, 1)
    p1 = FFI::Pointer.new p1
    ms1 = Forchess::Move::ManagedMoveStruct.new p1
    ms1[:value] = 1
    p2 = FFI::MemoryPointer.new(Forchess::Move::ManagedMoveStruct, 1)
    p2 = FFI::Pointer.new p2
    ms2 = Forchess::Move::ManagedMoveStruct.new p2
    ms2[:value] = 2
    p3 = FFI::MemoryPointer.new(Forchess::Move::ManagedMoveStruct, 1)
    p3 = FFI::Pointer.new p3
    ms3 = Forchess::Move::ManagedMoveStruct.new p3
    ms3[:value] = 1
    m1 = Forchess::Move.new p1, :coords
    m2 = Forchess::Move.new p2, :coords
    m3 = Forchess::Move.new p3, 14
    assert(m1 == m2)
    assert(m1 != m3)
    assert(m1 < m2)
    assert(m1 >= m3)
  end

  def test_set_value
    move = Forchess::Move.new
    assert_not_equal 128465, move.value
    move.value = 128465
    assert_equal 128465, move.value
  end
end

require 'ffi'

require 'forchess/common'
require 'forchess/move'
require 'forchess/move_list/struct'

module Forchess
  class MoveList
    include Enumerable
    include Forchess::Common

    attach_function :fc_mlist_init, [:pointer], :int
    def initialize (board, ptr=nil)
      @board = board
      if ptr.nil?
        @move_list = create_struct_object(ManagedMoveListStruct)
        Forchess.fc_mlist_init(@move_list)
      else
        @move_list = create_struct_object(MoveListStruct, ptr)
      end
      @length = nil
    end

    def to_ptr
      @move_list
    end

    attach_function :fc_mlist_length, [:pointer], :int
    def length
      @length ||= Forchess.fc_mlist_length(@move_list)
    end
    alias :size :length

    attach_function :fc_mlist_insert, [:pointer, :pointer, :int32], :int
    def << (move)
      if move.value != 0
        value = move.value
      elsif move.opp_piece != :none
        value = @board.material_value[move.opp_piece]
      else
        value = 0
      end

      Forchess.fc_mlist_insert(@move_list, move.to_ptr, value)
      @length = nil
      move
    end

    attach_function :fc_mlist_merge, [:pointer, :pointer], :int
    def + (other)
      ret = MoveList.new @board
      Forchess.fc_mlist_merge(ret.to_ptr, self.to_ptr)
      Forchess.fc_mlist_merge(ret.to_ptr, other.to_ptr)
      ret
    end

    attach_function :fc_mlist_delete, [:pointer, :int], :int
    def delete_at (idx)
      ret = self[idx]
      Forchess.fc_mlist_delete(@move_list, idx)
      @length = nil
      ret
    end

    def delete (move)
      i = 0
      while i < self.length
        if self[i] == move
          return self.delete_at i
        end
        i += 1
      end
      nil
    end

    attach_function :fc_mlist_get, [:pointer, :int], :pointer
    def [] (idx)
      idx = self.length + idx if idx < 0 # handle negative indices
      return nil if idx < 0 or idx >= self.length
      ref = FFI::MemoryPointer.new :pointer
      ref = Forchess.fc_mlist_get(@move_list, idx)
      Move.new(ref, @board.coords_from_move(ref))
    end

    def each
      self.length.times { |i| yield self[i] }
    end
  end
end

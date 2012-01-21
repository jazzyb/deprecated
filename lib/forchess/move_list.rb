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

    attach_function :fc_mlist_get, [:pointer, :int], :pointer
    def [] (idx)
      idx = self.length + idx if idx < 0 # handle negative indices
      return nil if idx >= self.length
      ref = FFI::MemoryPointer.new :pointer
      ref = Forchess.fc_mlist_get(@move_list, idx)
      # TODO handle error if ptr is nil
      Move.new(ref, @board.coords_from_move(ref))
    end

    def each
      idx = 0
      while idx < self.length
        yield self[idx]
        idx += 1
      end
    end
  end
end

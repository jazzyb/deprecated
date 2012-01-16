require 'ffi'

require 'forchess/common'
require 'forchess/move'
require 'forchess/move_list/struct'

module Forchess
  class MoveList
    include Enumerable
    include Forchess::Common

    attach_function :fc_mlist_init, [:pointer], :int
    def initialize (ptr=nil)
      if ptr.nil?
        @move_list = create_struct_object(ManagedMoveListStruct)
        Forchess.fc_mlist_init(@move_list)
      else
        @move_list = create_struct_object(MoveListStruct, ptr)
      end
    end

    def to_ptr
      @move_list
    end

    attach_function :fc_mlist_length, [:pointer], :int
    def length
      Forchess.fc_mlist_length(@move_list)
    end
    alias :size :length

    attach_function :fc_mlist_get, [:pointer, :int], :pointer
    # TODO handle negative indices
    def [] (idx)
      return nil if idx >= self.length
      ref = FFI::MemoryPointer.new :pointer
      ref = Forchess.fc_mlist_get(@move_list, idx)
      # TODO handle error if ptr is nil
      Move.new ref
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

require 'ffi'
require 'forchess/move'

module Forchess
  module MoveListLayout
    def self.included (base)
      base.class_eval do
        layout :moves, :pointer,
               :index, :uint32
      end
    end
  end

  class ManagedMoveListStruct < FFI::ManagedStruct
    include MoveListLayout

    def self.release (ptr)
      Forchess.fc_mlist_free(ptr)
      Forchess.free_object(ptr)
    end
  end

  class MoveListStruct < FFI::Struct
    include MoveListLayout
  end

  class MoveList
    def initialize (ptr=nil, type=:managed_struct)
      if ptr.nil?
        ptr = FFI::MemoryPointer.new(MoveListStruct, 1)
        # this useless cast gets around a bug in my version of FFI
        ptr = FFI::Pointer.new ptr
      end

      if type == :managed_struct
        @move_list = ManagedMoveListStruct.new ptr
        Forchess.fc_mlist_init(@move_list)
        # TODO handle malloc failure
      else
        @move_list = MoveListStruct.new ptr
      end
    end

    def length
      Forchess.fc_mlist_length(@move_list)
    end

    def [] (idx)
      return nil if idx >= self.length
      ret = FFI::MemoryPointer.new :pointer
      ret = Forchess.fc_mlist_get(@move_list, idx)
      # TODO handle error if ptr is nil
      Move.new(ret, :reference) # reference tells ruby not to free the object
    end

    def each
      idx = 0
      while idx < self.length
        yield self[idx]
        idx += 1
      end
    end

    def to_ptr
      @move_list
    end
  end

  # :pointer is an mlist
  attach_function :fc_mlist_init, [:pointer], :int
  attach_function :fc_mlist_free, [:pointer], :void
  attach_function :fc_mlist_length, [:pointer], :int
  # returns a pointer to a move
  attach_function :fc_mlist_get, [:pointer, :int], :pointer
end

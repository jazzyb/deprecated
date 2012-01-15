require 'ffi'
require 'forchess/player'
require 'forchess/move'
require 'forchess/move_list'

module Forchess
  NUM_PIECES = 6
  TOTAL_BITBOARDS = 29

  module BoardLayout
    def self.included (base)
      base.class_eval do
        layout :bitb, [:uint64, Forchess::TOTAL_BITBOARDS],
               :piece_value, [:int, Forchess::NUM_PIECES]
      end
    end
  end

  class ManagedBoardStruct < FFI::ManagedStruct
    include BoardLayout

    def self.release (ptr)
      Forchess.free_object(ptr)
    end
  end

  class BoardStruct < FFI::Struct
    include BoardLayout
  end

  class Board
    def initialize (ptr=nil, type=:managed_struct)
      if ptr.nil?
        ptr = FFI::MemoryPointer.new(ManagedBoardStruct, 1)
        # this useless cast gets around a bug in my version of FFI
        ptr = FFI::Pointer.new ptr
      end

      if type == :managed_struct
        @board = ManagedBoardStruct.new ptr
        Forchess.fc_board_init(@board)
      else
        @board = BoardStruct.new ptr
      end
    end

    def setup (filename)
      dummy = FFI::MemoryPointer.new :pointer
      Forchess.fc_board_setup(@board, filename, dummy)
      # TODO check for error
      line = IO.readlines(filename).first
      Player[line.split[0].to_i - 1] # return the first player
    end

    def moves (player)
      moves = MoveList.new
      Forchess.fc_board_get_moves(@board, moves.to_ptr, player)
      moves
    end
  end

  attach_function :fc_board_init, [:pointer], :int
  attach_function :fc_board_setup, [:pointer, :string, :pointer], :int
  attach_function :fc_board_get_moves, [:pointer, :pointer, Player], :void
end

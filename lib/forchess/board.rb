require 'ffi'

require 'forchess/board_struct'
require 'forchess/common'
require 'forchess/move'
require 'forchess/move_list'
require 'forchess/player'

module Forchess
  class Board
    include Forchess::Common

    def initialize (ptr=nil)
      if ptr.nil?
        @board = create_struct_object(ManagedBoardStruct)
        Forchess.fc_board_init(@board)
      else
        @board = create_struct_object(BoardStruct, ptr)
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

    def to_ptr
      @board
    end
  end

  attach_function :fc_board_init, [:pointer], :int
  attach_function :fc_board_setup, [:pointer, :string, :pointer], :int
  attach_function :fc_board_get_moves, [:pointer, :pointer, Player], :void
end

require 'ffi'

require 'forchess/board/struct'
require 'forchess/common'
require 'forchess/material_value'
require 'forchess/move'
require 'forchess/move_list'
require 'forchess/piece'
require 'forchess/player'

module Forchess
  class Board
    include Forchess::Common
    attr_accessor :material_value

    attach_function :fc_board_init, [:pointer], :int
    def initialize (filename=nil)
      @board = create_struct_object(ManagedBoardStruct)
      Forchess.fc_board_init(@board)
      if not filename.nil?
        setup(filename)
      end
      @material_value = MaterialValue.new(@board)
    end

    def to_ptr
      @board
    end

    attach_function :fc_board_setup, [:pointer, :string, :pointer], :int
    def setup (filename)
      player = FFI::MemoryPointer.new(:int, 1)
      Forchess.fc_board_setup(@board, filename, player)
      # TODO check for error
      Player[player.get_int(0)]
    end

    attach_function :fc_board_set_piece, [:pointer, Player, Piece, :int, :int],
      :int
    # parameters are of types Player, Piece, [Integer, Integer], respectively
    def set_piece (player, piece, coords)
      # TODO check return code for error
      Forchess.fc_board_set_piece(@board, player, piece, *coords)
    end

    attach_function :fc_board_get_piece,
      [:pointer, :pointer, :pointer, :int, :int], :int
    # parameter is of type [Integer, Integer]
    # returns type {:player => Player, :piece => Piece}
    def get_piece (coords)
      player = FFI::MemoryPointer.new(:int, 1)
      piece = FFI::MemoryPointer.new(:int, 1)
      Forchess.fc_board_get_piece(@board, player, piece, *coords)
      {:player => Player[player.get_int(0)], :piece => Piece[piece.get_int(0)]}
    end

    attach_function :fc_board_remove_piece, [:pointer, :int, :int], :int
    def remove_piece (coords)
      # TODO check return code for error
      Forchess.fc_board_remove_piece(@board, *coords)
    end

    attach_function :fc_board_get_moves, [:pointer, :pointer, Player], :void
    def moves (player)
      moves = MoveList.new
      Forchess.fc_board_get_moves(@board, moves.to_ptr, player)
      moves
    end
  end
end

require 'ffi'

require 'forchess/board/check_status'
require 'forchess/board/material_value'
require 'forchess/board/struct'
require 'forchess/common'
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
    def get_moves (player)
      moves = MoveList.new
      Forchess.fc_board_get_moves(@board, moves.to_ptr, player)
      moves
    end

    attach_function :fc_board_make_move, [:pointer, :pointer], :int
    def move (move_obj)
      # TODO check return condition for promotion requirement
      Forchess.fc_board_make_move(@board, move_obj.to_ptr)
    end

    attach_function :fc_board_check_status, [:pointer, Player], :int
    def check_status (player)
      CheckStatus[Forchess.fc_board_check_status(@board, player)]
    end

    attach_function :fc_board_is_player_out, [:pointer, Player], :int
    def player_out? (player)
      Forchess.fc_board_is_player_out(@board, player) == 1
    end

    attach_function :fc_board_game_over, [:pointer], :int
    def game_over?
      Forchess.fc_board_game_over(@board) == 1
    end

    attach_function :fc_board_score_position, [:pointer, Player], :int
    def score (player)
      Forchess.fc_board_score_position(@board, player)
    end
  end
end

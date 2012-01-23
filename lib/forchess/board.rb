require 'ffi'

require 'forchess/assertion'
require 'forchess/board/check_status'
require 'forchess/board/material_value'
require 'forchess/board/placement'
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
      setup(filename) unless filename.nil?
      @material_value = MaterialValue.new(@board)
    end

    def to_ptr
      @board
    end

    attach_function :fc_board_setup, [:pointer, :string, :pointer], :int
    def setup (filename)
      player = FFI::MemoryPointer.new(:int, 1)
      rc = Forchess.fc_board_setup(@board, filename, player)
      raise "invalid forchess format for file '#{filename}'" if rc == 0
      Player[player.get_int(0)]
    end

    attach_function :fc_board_get_moves, [:pointer, :pointer, Player], :void
    def get_moves (player)
      moves = MoveList.new self
      Forchess.fc_board_get_moves(@board, moves.to_ptr, player)
      moves
    end

    attach_function :fc_board_make_move, [:pointer, :pointer], :int
    def move (move_obj)
      rc = Forchess.fc_board_make_move(@board, move_obj.to_ptr)
      raise "move requires promotion to be set" if rc == 0
      nil
    end

    # coords is of type [[x1, y1], [x2, y2]]
    def create_move (coords)
      ret = Move.new nil, coords
      hash = self.get_piece(coords[0])
      ret.to_ptr[:player] = hash[:player]
      ret.to_ptr[:piece] = hash[:piece]
      hash = (coords[1].nil?) ? Hash.new(:none) : self.get_piece(coords[1])
      ret.to_ptr[:opp_player] = hash[:player]
      ret.to_ptr[:opp_piece] = hash[:piece]
      ret.to_ptr[:move] = _coords_to_bitfield(coords)
      ret.to_ptr[:value] = 0
      ret
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

    def coords_from_move (move_ptr)
      move = Move.new move_ptr
      bitfield = move.move
      return bitfield if bitfield.kind_of? Enumerable

      coords = _bitfield_to_coords bitfield
      piece = self.get_piece coords[0]
      if piece[:piece] == move.piece and piece[:player] == move.player
        return coords

      elsif piece[:piece] == move.opp_piece and
            piece[:player] == move.opp_player
        return coords.reverse

      else
        raise Forchess::Assertion.new "#{piece}::#{move}"
      end
    end

    private

    def _bitfield_to_coords (bf)
      coords = []
      64.times do |i|
        if ((2 ** i) & bf) != 0
          coords << [i % 8, i / 8]
        end
      end
      coords
    end

    def _coords_to_bitfield (coords)
      start, finish = coords
      bf = 2 ** (start[1] * 8 + start[0])
      return bf if finish.nil?
      bf | (2 ** (finish[1] * 8 + finish[0]))
    end
  end
end

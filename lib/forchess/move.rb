require 'ffi'

require 'forchess/common'
require 'forchess/move/struct'
require 'forchess/piece'
require 'forchess/player'

module Forchess
  class Move
    include Forchess::Common

    def initialize (ptr=nil)
      if ptr.nil?
        @move = create_struct_object(ManagedMoveStruct)
      else
        @move = create_struct_object(MoveStruct, ptr)
      end
    end

    def to_ptr
      @move
    end

    def == (other)
      self.move == other.move
    end

    def player
      @move[:player]
    end

    def piece
      @move[:piece]
    end

    def opp_player
      @move[:opp_player]
    end

    def opp_piece
      @move[:opp_piece]
    end

    attach_function :fc_move_set_promotion, [:pointer, Piece], :void
    def promotion= (piece)
      Forchess.fc_move_set_promotion(@move, piece)
      promotion
    end

    def promotion
      @move[:promote]
    end

    # NOTE:  This is technically public, but it should only ever be called
    # from Board#get_moves
    def _set_move (coords)
      @coords = coords
    end

    def move
      @coords or @move[:move]
    end

    def value
      @move[:value]
    end
  end
end

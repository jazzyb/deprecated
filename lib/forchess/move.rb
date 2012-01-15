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

    def move
      # TODO return [ [x1, y1], [x2, y2] ]
    end

    def value
      @move[:value]
    end

    def to_ptr
      @move
    end
  end
end

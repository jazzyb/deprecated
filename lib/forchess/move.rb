require 'ffi'

require 'forchess/common'
require 'forchess/move/struct'
require 'forchess/piece'
require 'forchess/player'

module Forchess
  class Move
    include Comparable
    include Forchess::Common

    def initialize (ptr=nil, coords=nil)
      if ptr.nil?
        @move = create_struct_object(ManagedMoveStruct)
      else
        @move = create_struct_object(MoveStruct, ptr)
      end
      @coords = coords
    end

    def to_ptr
      @move
    end

    def to_s
      "#{player} #{piece} #{opp_player} #{opp_piece} #{move} #{value}"
    end

    def <=> (other)
      self.value <=> other.value
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

    def move
      @coords or @move[:move]
    end

    def value
      @move[:value]
    end

    def value= (new_val)
      @move[:value] = new_val
    end
  end
end

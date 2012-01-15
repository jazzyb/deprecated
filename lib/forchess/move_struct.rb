require 'ffi'

require 'forchess/piece'
require 'forchess/player'

module Forchess
  module MoveLayout
    def self.included (base)
      base.class_eval do
        layout :player, Player,
               :piece, Piece,
               :opp_player, Player,
               :opp_piece, Piece,
               :promote, Piece,
               :move, :uint64,
               :value, :int32
      end
    end
  end

  class ManagedMoveStruct < FFI::ManagedStruct
    include MoveLayout

    def self.release (ptr)
      Forchess.free_object(ptr)
    end
  end

  class MoveStruct < FFI::Struct
    include MoveLayout
  end
end

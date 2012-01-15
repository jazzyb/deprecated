require 'ffi'
require 'forchess/player'
require 'forchess/piece'

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

  class Move
    # ptr is an FFI::MemoryPointer
    def initialize (ptr=nil, type=:managed_struct)
      if ptr.nil?
        ptr = FFI::MemoryPointer.new(MoveStruct, 1)
        # this useless cast gets around a bug in my version of FFI
        ptr = FFI::Pointer.new ptr
      end

      if type == :managed_struct
        @move = ManagedMoveStruct.new ptr
      else
        @move = MoveStruct.new ptr
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
  end

  # :pointer is a move
  attach_function :fc_move_set_promotion, [:pointer, Piece], :void
  attach_function :fc_move_copy, [:pointer, :pointer], :void
end

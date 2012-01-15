require 'ffi'

module Forchess
  class Board
    NUM_PIECES = 6
    TOTAL_BITBOARDS = 29

    module BoardLayout
      def self.included (base)
        base.class_eval do
          layout :bitb, [:uint64, Forchess::Board::TOTAL_BITBOARDS],
                 :piece_value, [:int, Forchess::Board::NUM_PIECES]
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
  end
end

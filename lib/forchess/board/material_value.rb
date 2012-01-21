require 'ffi'

require 'forchess/common'
require 'forchess/piece'

module Forchess
  class Board
    class MaterialValue
      include Forchess::Common

      def initialize (board)
        @board = board
      end

      attach_function :fc_board_set_material_value, [:pointer, Piece, :int],
        :void
      def []= (piece, value)
        Forchess.fc_board_set_material_value(@board, piece, value)
        value
      end

      attach_function :fc_board_get_material_value, [:pointer, Piece], :int
      def [] (piece)
        Forchess.fc_board_get_material_value(@board, piece)
      end
    end
  end
end

require 'ffi'

require 'forchess/assertion'

module Forchess
  attach_function :fc_board_set_piece, [:pointer, Player, Piece, :int, :int], :int
  attach_function :fc_board_get_piece, [:pointer, :pointer, :pointer, :int, :int], :int
  attach_function :fc_board_remove_piece, [:pointer, :int, :int], :int

  class Board
    # parameters are of types Player, Piece, [Integer, Integer], respectively
    def set_piece (player, piece, coords)
      # NOTE: we call coords.reverse because libforchess takes these values as
      # row/col whereas this wrapper assumes they are x/y coords, see also
      # get_piece and remove_piece
      rc = Forchess.fc_board_set_piece(@board, player, piece, *(coords.reverse))
      raise 'unable to set piece on board' if rc == 0
      {:player => player, :piece => piece}
    end

    # parameter is of type [Integer, Integer]
    def get_piece (coords)
      player = FFI::MemoryPointer.new(:int, 1)
      piece = FFI::MemoryPointer.new(:int, 1)
      Forchess.fc_board_get_piece(@board, player, piece, *(coords.reverse))
      {:player => Player[player.get_int(0)], :piece => Piece[piece.get_int(0)]}
    end

    def remove_piece (coords)
      ret = self.get_piece(coords)
      Forchess.fc_board_remove_piece(@board, *(coords.reverse))
      ret
    end

    def [] (idx)
      Column.new self, idx
    end

    class Column
      def initialize (board, idx)
        @board = board
        @idx = _sanitize_index('a', 'h', idx)
      end

      def [] (idy)
        idy = _sanitize_index('1', '8', idy)
        @board.get_piece([@idx, idy])
      end

      def []= (idy, hash)
        idy = _sanitize_index('1', '8', idy)
        if hash[:player] == :none and hash[:piece] == :none
          @board.remove_piece([@idx, idy])
        else
          @board.set_piece(hash[:player], hash[:piece], [@idx, idy])
        end
      end

      private

      def _sanitize_index (first, last, idx)
        if idx.kind_of? String
          if idx.length != 1 or idx < first or idx > last
            raise "index of '#{idx}' is out of range"
          end
          return idx.ord - first.ord

        elsif idx.kind_of? Integer
          if idx < 0 or idx > 7
            raise "index of '#{idx}' is out of range"
          end
          return idx

        else
          raise Forchess::Assertion.new idx.class
        end
      end
    end
  end
end

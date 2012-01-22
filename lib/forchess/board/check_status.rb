require 'forchess/player'

module Forchess
  CheckStatus = enum( :none, 0,
                      :check, 1,
                      :checkmate, 2 )

  attach_function :fc_board_check_status, [:pointer, Player], :int

  class Board
    def check_status (player)
      CheckStatus[Forchess.fc_board_check_status(@board, player)]
    end

    def check? (player)
      self.check_status == :check
    end

    def checkmate? (player)
      self.check_status == :checkmate
    end
  end
end

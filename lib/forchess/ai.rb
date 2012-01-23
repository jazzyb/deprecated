require 'ffi'

require 'forchess/ai/algorithm'
require 'forchess/ai/struct'
require 'forchess/board'
require 'forchess/common'
require 'forchess/move'
require 'forchess/move_list'
require 'forchess/player'

module Forchess
  class AI
    include Forchess::Common
    attr_reader :board, :algorithm

    attach_function :fc_ai_init, [:pointer, :pointer], :void
    def initialize (board, algo=:negascout)
      @ai = create_struct_object(ManagedAIStruct)
      Forchess.fc_ai_init(@ai, board.to_ptr)
      @board = board
      self.algorithm = algo
    end

    def to_ptr
      @ai
    end

    attach_function :fc_ai_set_algorithm, [:pointer, Algorithm], :void
    def algorithm= (algo)
      Forchess.fc_ai_set_algorithm(@ai, algo)
      @algorithm = algo
    end

    attach_function :fc_ai_next_ranked_moves,
      [:pointer, :pointer, :pointer, Player, :int, :uint], :int
    # NOTE:  The move_list parameter below is a MoveList of moves that the
    # caller may request the AI search through INSTEAD OF player's valid
    # moves.  An example of how this might be used would be if a caller
    # searched at a shallow depth and then used the returned move_list to
    # search at a deeper depth; the hypothesis being that the best move at the
    # deeper depth would also be one of the top moves from the shallower
    # search.  Such a strategy could potentially speed-up the deeper search.
    def next_sorted_moves (player, depth, seconds=0, move_list=nil)
      move_list = move_list.to_ptr unless move_list.nil?
      moves = MoveList.new @board
      rc = Forchess.fc_ai_next_ranked_moves(@ai, moves.to_ptr, move_list,
                                            player, depth, seconds)
      raise 'AI failed to find a move' if rc == 0
      moves
    end

    def next_move (*args)
      self.next_sorted_moves(*args)[0]
    end
  end
end

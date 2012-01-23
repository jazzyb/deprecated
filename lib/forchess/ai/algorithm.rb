require 'ffi'

module Forchess
  Algorithm = enum( :alphabeta, 0,
                    :negascout )
end

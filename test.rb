#!/Users/jazzyb/.rvm/rubies/ruby-1.9.2-p180/bin/ruby -Ilib
require 'forchess'

b = Forchess::Board.new
player = b.setup(ARGV[0])
puts player
b.moves(:first).each do |move|
  puts "[#{move.player} #{move.piece}] takes [#{move.opp_player} #{move.opp_piece}]"
end

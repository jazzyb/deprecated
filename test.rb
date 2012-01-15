#!/Users/jazzyb/.rvm/rubies/ruby-1.9.2-p180/bin/ruby -Ilib
require 'forchess'

b = Forchess::Board.new(ARGV[0])
puts b.setup(ARGV[0])

b.set_piece(:second, :knight, [2, 2])
puts b.get_piece([2, 2])
puts '-' * 30
b.remove_piece([2, 2])

b.get_moves(:first).each do |move|
  puts "[#{move.player} #{move.piece}] takes [#{move.opp_player} #{move.opp_piece}]"
end

b.move(b.get_moves(:first)[3])
puts '-' * 30
b.get_moves(:second).each do |move|
  puts "[#{move.player} #{move.piece}] takes [#{move.opp_player} #{move.opp_piece}]"
end

#!/usr/bin/ruby
# WARNING: This library will likely not work on anything other than a
# little-endian machine due to my method of unpacking the structures of the SWF
# binary.

require 'swf_boat'

s = SWFBoat::FlashFile.new ARGV[0]
s.read
s.tags.each do |tag|
  next unless tag.is_a? SWFBoat::Tag::DoABC
  puts tag.name
  tag.decompile
end

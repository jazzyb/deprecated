#!/usr/bin/env ruby

first_word = true
File.open(ARGV[0]) do |file|
  file.each do |line|
    if line.strip == ''
      first_word = true
      puts line, ''
      next
    end

    line.split.each do |word|
      if first_word
        word.capitalize!
        first_word = false
      else
        word.downcase!
      end

      if ['.', '?', '!', ':'].include?(word.sub(/"\Z/, '')[-1].chr)
        first_word = true
      end

      print word.sub(/(\A.*?)hulk(.*\Z)/i, '\1Bruce\2'), ' '
    end
  end
end

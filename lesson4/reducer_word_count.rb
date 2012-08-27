#!/usr/bin/env ruby

current_word = nil
current_count = 0

STDIN.each do |line|
  word, count = line.split("\t")
  count = count.to_i

  # the shuffle between the map and reduce phase sorts the
  # input to the reducer. So we know we'll be getting all
  # the same words together. Look for the change and output the
  # total when it happens
  if word == current_word
    current_count += count
  elsif current_word
    puts "#{current_word}\t#{current_count}"
    current_count = count
  end

  current_word = word
end

#!/usr/bin/env ruby

current_tag = nil
current_count = 0

STDIN.each do |line|
  tag, count = line.split("\t")
  count = count.to_i

  # the shuffle between the map and reduce phase sorts the
  # input to the reducer. So we know we'll be getting all
  # the same tags together. Look for the change and output the
  # total when it happens
  if tag == current_tag
    current_count += count
  elsif current_tag
    puts "#{current_tag}\t#{current_count}"
    current_count = count
  end

  current_tag = tag
end

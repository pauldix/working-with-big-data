#!/usr/bin/env ruby

STDIN.each do |line|
  tag, count = line.strip.split("\t")
  puts "#{count}\t#{tag}"
end

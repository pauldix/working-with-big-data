#!/usr/bin/env ruby

STDIN.each do |line|
  count, tag = line.strip.split("\t")
  puts "#{tag}\t#{count}"
end

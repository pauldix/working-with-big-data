#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'active_support/core_ext/numeric/time'

current_count = 0
current_tag = nil
tags = []

STDIN.each do |line|
  tag, count, time = line.split
  count = count.to_i
  time = Time.at(time.to_i)

  if current_tag != tag && !current_tag.nil?
    tags << [current_count, current_tag]
    current_count = 0
  end

  current_count += count
  current_tag = tag
end

tags = tags.sort {|a, b| b.first <=> a.first}
puts tags.to_json

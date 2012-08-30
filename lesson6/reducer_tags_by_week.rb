#!/usr/bin/env ruby

require 'rubygems'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/date/calculations'
require 'json'

current_tag = nil
week_counts = Hash.new {|h, k| h[k] = 0}

STDIN.each do |line|
  tag, count, time = line.split
  count = count.to_i
  time = Time.at(time.to_i)

  if current_tag != tag && !current_tag.nil?
    weeks = week_counts.to_a.sort {|a, b| a.first <=> b.first}
    weeks = weeks.map {|week| [week.first.to_i * 1000, week.last]}

    json = {:tag => current_tag, :data => weeks}.to_json
    puts json

    week_counts = Hash.new {|h, k| h[k] = 0}
  end

  week = time.beginning_of_week
  week_counts[week] += count
  current_tag = tag
end

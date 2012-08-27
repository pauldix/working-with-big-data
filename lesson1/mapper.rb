#!/usr/bin/env ruby

STDIN.each do |line|
  # only look at tags for posts, not questions
  if line.index('PostTypeId="1"')

    # this is the ghetto way we're going to pull the tags out of this string
    tags_match = line.match(/Tags=(".*?")/)
    if tags_match
      tags = tags_match[0]
      tags = tags.split("&gt;").map {|s| s.gsub(/.*\&lt\;/, '')}
      tags = tags.slice(0, tags.length - 2)

      # loop through and put to standard out in tab delimited for the reducer to pick up
      tags.each do |tag|
        puts "#{tag}\t1"
      end
    end
  end
end

#!/usr/bin/env ruby

require "#{File.dirname(__FILE__)}/post_info_extractor.rb"

STDIN.each do |line|
  # only look at tags for posts, not questions
  if is_question?(line)
    post_id, title, body, tags = extract_post_info(line)

    puts "#{post_id}\t#{tags.join(",")}"
  end
end

#!/usr/bin/env ruby

# first read in the dictionary
tag_to_array_position = {}

File.open("tags.txt") do |tags_file|
  tags_file.each_line do |line|
    tag_to_array_position[line.split.first] = tag_to_array_position.size
  end
end

require "#{File.dirname(__FILE__)}/post_info_extractor.rb"

STDIN.each do |line|
  # only look at tags for posts, not questions
  if is_question?(line)
    post_id, title, body, tags = extract_post_info(line)

    array_positions_and_counts = []
    tags.each do |tag|
      if position = tag_to_array_position[tag]
        array_positions_and_counts << [position, 1]
      end
    end

    array_positions_and_counts = array_positions_and_counts.sort {|a, b| a.first <=> b.first}

    features_as_string = array_positions_and_counts.map {|a| a.join(",")}.join("|")

    puts "#{post_id}\t#{features_as_string}"
  end
end

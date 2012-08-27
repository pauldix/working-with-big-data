#!/usr/bin/env ruby

# first read in the dictionary
word_to_array_position = {}

File.open("words.txt") do |words_file|
  words_file.each_line do |line|
    word_to_array_position[line.strip] = word_to_array_position.size
  end
end

require "#{File.dirname(__FILE__)}/post_info_extractor.rb"

STDIN.each do |line|
  # only look at tags for posts, not questions
  if is_question?(line)
    post_id, title, body, tags = extract_post_info(line)

    word_counts = Hash.new {|h, k| h[k] = 0}
    (title.split + body.split).each do |word|
      word_counts[word] += 1
    end

    array_positions_and_counts = []
    word_counts.each_pair do |word, count|
      if position = word_to_array_position[word]
        array_positions_and_counts << [position, count]
      end
    end

    array_positions_and_counts = array_positions_and_counts.sort {|a, b| a.first <=> b.first}

    features_as_string = array_positions_and_counts.map {|a| a.join(",")}.join("|")

    puts "#{post_id}\t#{features_as_string}"
  end
end

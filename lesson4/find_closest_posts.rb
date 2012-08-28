require 'rubygems'
require 'json'

require "#{File.dirname(__FILE__)}/knn.rb"

raise "You must specify a post to check against: ruby find_closest_posts.rb 2343" if ARGV.empty?

post_id = ARGV[0]

knn = Knn.new

puts "Reading post arrays"
File.open("post_arrays.txt") do |file|
  file.each_line do |line|
    tab_index = line.index(/\s/)
    id    = line.slice(0, tab_index)
    json  = line.slice(tab_index + 1, line.length).strip
    array = JSON.parse(json)

    knn.add_instance(array, id)
  end
end

post_title = `grep #{post_id} post_words.txt`.split("\t")[1]
puts "Checking for posts similar to #{post_title}"
post_array = knn.get_instance_for_id(post_id)
neighbors = knn.find_nearest_neighbors(post_array, 30, true)

tag_counts = Hash.new {|h, k| h[k] = 0}

puts "Neighbors:"
neighbors.each do |neighbor|
  neighbor_id, distance = neighbor

  neighbor_tags = `grep #{neighbor_id} post_tags.txt`
  neighbor_tags.split.last.split(",").each do |tag|
    tag_counts[tag] += 1
  end

  puts "#{distance} - " + `grep #{neighbor_id} post_words.txt`.split("\t")[1]
end

ordered_tags = tag_counts.to_a.sort {|a, b| b.last <=> a.last}
puts ordered_tags.slice(0, 10).map {|tag_and_count| tag_and_count.join(" - ")}.join("\n")
puts "Acutal post tags:"
puts `grep #{post_id} post_tags.txt`

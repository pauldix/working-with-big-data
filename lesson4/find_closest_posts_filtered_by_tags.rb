require 'rubygems'
require 'json'

require "#{File.dirname(__FILE__)}/knn.rb"

raise "You must specify a post to check against: ruby find_closest_posts.rb 2343" if ARGV.empty?

post_id = ARGV[0]

puts "Building tag index"
tag_index = Hash.new {|h, k| h[k] = []}
File.open("post_tags.txt") do |file|
  file.each_line do |line|
    tab_index = line.index(/\s/)
    id        = line.slice(0, tab_index)
    tags      = line.slice(tab_index + 1, line.length).strip.split(",")

    tags.each do |tag|
      tag_index[tag] << id
    end
  end
end

puts "Building dictionary"
# first read in the dictionary
word_to_array_position = {}

File.open("words.txt") do |words_file|
  words_file.each_line do |line|
    word_to_array_position[line.strip] = word_to_array_position.size
  end
end

all_posts_knn = Knn.new()

puts "Reading post arrays"
File.open("post_arrays.txt") do |file|
  file.each_line do |line|
    tab_index = line.index(/\s/)
    id    = line.slice(0, tab_index)
    json  = line.slice(tab_index + 1, line.length).strip
    array = JSON.parse(json)

    all_posts_knn.add_instance(array, id)
  end
end

# find the posts we want to compare against
id, title, body = `grep #{post_id} post_words.txt`.split("\t")
posts_to_compare = {}
(title + body).split.each do |word|
  if tag_index.has_key?(word)
    puts "Comparing posts with tag: #{word}"
    tag_index[word].each do |compare_id|
      posts_to_compare[compare_id] = true
    end
  end
end

# now use a knn that is limited to only the posts we filtered on
knn = Knn.new
posts_to_compare.keys.each do |compare_id|
  instance = all_posts_knn.get_instance_for_id(compare_id)
  knn.add_instance(instance, compare_id)
end

puts "Checking for posts similar to #{title}"
post_array = all_posts_knn.get_instance_for_id(post_id)
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

# go through adding some timing to see how this works. last time is the real
require 'benchmark'
puts Benchmark.measure {
  1000000.times {Math.sqrt(2342323)}
}

# do this after the first part. the check to see how effective this is vs. no knn at all
puts "\n\n\n******************************"
puts "Neighbors with no knn:"
tag_counts = Hash.new {|h, k| h[k] = 0}
posts_to_compare.keys.each do |compare_id|
  neighbor_tags = `grep #{compare_id} post_tags.txt`
  neighbor_tags.split.last.split(",").each do |tag|
    tag_counts[tag] += 1
  end

#  puts `grep #{compare_id} post_words.txt`.split("\t")[1]
end

ordered_tags = tag_counts.to_a.sort {|a, b| b.last <=> a.last}
puts ordered_tags.slice(0, 10).map {|tag_and_count| tag_and_count.join(" - ")}.join("\n")

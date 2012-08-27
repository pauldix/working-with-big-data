require "#{File.dirname(__FILE__)}/knn.rb"

raise "You must specify a post to check against: ruby find_closest_posts_by_tags.rb 2343" if ARGV.empty?

post_id = ARGV[0]

knn = Knn.new

puts "Reading post arrays"
File.open("post_tag_arrays.txt") do |file|
  file.each_line do |line|
    id, array = line.split

    if array # could have posts with no tags
      array = array.split("|").map do |index_and_count|
        index_and_count.split(",").map {|num| num.to_i}
      end

      knn.add_instance(array, id)
    end
  end
end

post_words = `grep #{post_id} post_words.txt`
post_title = post_words.split("\t")[1]
post_words = post_title + post_title.split("\t").last

puts "Checking for posts similar to #{post_title}"

# extract the features
# first read in the dictionary
tag_to_array_position = {}

File.open("tags.txt") do |tags_file|
  tags_file.each_line do |line|
    tag_to_array_position[line.split.first] = tag_to_array_position.size
  end
end

# make the count of the words
post_word_counts = Hash.new {|h, k| h[k] = 0}
post_words.split.each do |word|
  post_word_counts[word] += 1
end

array_positions_and_counts = []
post_word_counts.each_pair do |word, count|
  if position = tag_to_array_position[word]
    array_positions_and_counts << [position, count]
  end
end

post_array = array_positions_and_counts.sort {|a, b| a.first <=> b.first}
# now compute neighbors

neighbors = knn.find_nearest_neighbors(post_array, 20, true)

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

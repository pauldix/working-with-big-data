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

class TagRecommender
  def initialize(knn, training_posts_tags)
    @knn = knn
    @training_posts_tags = training_posts_tags
  end

  def recommend_tags(post_array)
    neighbors = @knn.find_nearest_neighbors(post_array, 30, true)

    tag_counts = Hash.new {|h, k| h[k] = 0}

    neighbors.each do |neighbor|
      neighbor_id, distance = neighbor

      if tags = @training_posts_tags[neighbor_id]
        tags.each do |tag|
          tag_counts[tag] += 1
        end
      end

      # output the title of the neighbor
      puts "#{distance} - " + `grep #{neighbor_id} post_words.txt`.split("\t")[1]
    end

    ordered_tags = tag_counts.to_a.sort {|a, b| b.last <=> a.last}

    puts ordered_tags.slice(0, 10).map {|tag_and_count| tag_and_count.join(" - ")}.join("\n")

    ordered_tags.slice(0, 5).map {|tag_and_count| tag_and_count.first}
  end
end

post_tags = {}
puts "Reading post tags..."
File.open("post_tags.txt") do |file|
  file.each_line do |line|
    id, tags = line.split
    tags ||= ""
    tags = tags.split(",")
    post_tags[id] = tags
  end
end

tag_recommender = TagRecommender.new(knn, post_tags)

post_array = knn.get_instance_for_id(post_id)

post_title = `grep #{post_id} post_words.txt`.split("\t")[1]
puts "Checking for posts similar to #{post_title}"

tag_recommender.recommend_tags(post_array)

puts "Acutal post tags:"
puts `grep #{post_id} post_tags.txt`

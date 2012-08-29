require "#{File.dirname(__FILE__)}/knn.rb"
require "#{File.dirname(__FILE__)}/tag_recommender.rb"
require 'rubygems'
require 'json'

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

data = []
puts "Reading post arrays..."
File.open("post_arrays.txt") do |file|
  file.each_line do |line|
    tab_index = line.index(/\s/)
    id    = line.slice(0, tab_index)
    json  = line.slice(tab_index + 1, line.length).strip
    array = JSON.parse(json)

    # we're only going to use posts with tags. talk about
    # cleaning data, and if it's valid to exclude these
    if tags = post_tags[id]
      data << {:id => id, :array => array} unless tags.empty?
    end
  end
end

# shuffle the array. data could be time ordered or some other thing
data = data.shuffle.slice(0, 1000)

# 10x cross validation
data_size = data.length
test_size = data.length / 10
test_position = 0

# accuracy counters
posts_tested = 0
posts_correct = 0
posts_incorrect = 0
tags_correct = 0
tags_incorrect = 0
tags_missed = 0

while test_position < data_size
  # train the model on the training set
  knn = Knn.new
  training_set = data.slice(0, test_position) + data.slice(test_position, data_size)
  training_set.each do |instance|
    knn.add_instance(instance[:array], instance[:id])
  end
  tag_recommender = TagRecommender.new(knn, post_tags)

  # test against the test set
  test_set = data.slice(test_position, test_position + test_size)
  fold_correct   = 0
  fold_incorrect = 0
  fold_missed    = 0

  puts "testing against set #{test_position} to #{test_position + test_size} on #{data.size}"
  test_set.each do |test_instance|
    predicted_tags = tag_recommender.recommend_tags(test_instance[:array])
    observed_tags  = post_tags[test_instance[:id]]

    correct_predictions   = (predicted_tags & observed_tags).size
    incorrect_predictions = predicted_tags.size - correct_predictions
    missed_predictions    = observed_tags.size - correct_predictions

    if missed_predictions == 0 && incorrect_predictions == 0
      posts_correct += 1
    else
      posts_incorrect += 1
    end

    fold_correct   += correct_predictions
    fold_incorrect += incorrect_predictions
    fold_missed    += missed_predictions
  end

  tags_correct   += fold_correct
  tags_incorrect += fold_incorrect
  tags_missed    += fold_missed

  puts "Fold had #{fold_correct} correct #{fold_incorrect} incorrect #{fold_missed} missed"
  puts "#{fold_correct.to_f / (fold_incorrect + fold_missed) * 100}% accuracy"

  test_position += test_size
end

puts "cross validation run:"
puts "#{posts_correct} posts_correct"
puts "#{posts_incorrect} posts_incorrect"
puts "#{posts_correct.to_f / posts_incorrect.to_f}% accuracy"
puts "#{tags_correct} tags_correct"
puts "#{tags_incorrect} tags_incorrect"
puts "#{tags_missed} tags_missed"
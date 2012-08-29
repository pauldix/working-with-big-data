require 'rubygems'
require 'json'

# load up all the posts we're going to be running through cross validation runs with
puts "reading ids"
ids = []
File.open("post_tags.txt") do |file|
  file.each_line do |line|
    id, tags = line.split
    ids << id if tags # only use ids that have tags
  end
end

ids = ids.shuffle.slice(0, 100)

data_size = ids.length
test_size = ids.length / 10
test_position = 0

puts "writing cross validation runs"
File.open("cross_validation_runs.txt", "w+") do |file|
  while test_position < data_size do
    training_set = ids.slice(0, test_position) + ids.slice(test_position, data_size)
    test_set = ids.slice(test_position, test_position + test_size)
    test_position += test_size
    file.puts([training_set, test_set].to_json)
  end
end

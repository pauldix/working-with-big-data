require "#{File.dirname(__FILE__)}/knn.rb"

knn = Knn.new
knn.add_instance([[0, 1], [1, 3], [2, 1], [3, 6]], "paul")
knn.add_instance([[0, 1], [1, 3], [2, 1], [3, 6]], "paul2")
knn.add_instance([[0, 1]], "one rating")
knn.add_instance([[3, 5], [10, 1]], "skipped values")
knn.add_instance([[3, 6], [10, 1]], "skipped values closer")

puts knn.inspect
puts knn.find_nearest_neighbors([[0, 1], [1, 3], [2, 1], [3, 6]], 2).inspect
puts knn.find_nearest_neighbors([[0, 1], [1, 3], [2, 1], [3, 6]], 2, true).inspect
puts knn.find_nearest_neighbors([[3, 5], [10, 1]], 5).inspect
puts knn.find_nearest_neighbors([[21, 3]], 2).inspect
puts knn.find_nearest_neighbors([[3, 7], [10, 1]], 3).inspect
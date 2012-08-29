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
    end

    ordered_tags = tag_counts.to_a.sort {|a, b| b.last <=> a.last}

    ordered_tags.slice(0, 5).map {|tag_and_count| tag_and_count.first}
  end
end

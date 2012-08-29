require 'sinatra'

post_dictionary = load_dictionary # read in dictionary, store centrally, good for Hadoop
feature_extractor = PostFeatureExtractor.new(post_dictionary)

# load model, sometimes this will be very fast, but not with knn
training_posts = load_posts
knn = Knn.new
training_posts.each do |post|
  knn.add_instance(post.array, post.id)
end

# load the tags and inialize the recommender
post_tags = load_tags
recommender = TagRecommender.new(knn, post_tags)

post '/recommend_tags' do
  post_object = JSON.parse(request.body.read)

  # this will be fast
  sparse_feature_array = feature_extractor.extract_from_post(post_object)

  # this will be slow. where we'll want to optimize
  tags_with_confidence = recommender.recommend_tags(sparse_feature_array)

  # include some confidence metric for the recommendations. that way front
  # end developers will have a little more information and decide if they
  # want to show the recommendations
  tags_with_confidence.to_json
end

# that was a lot of data to load. also in memory
# so we should be multi-threaded and not multi-process

# with knn we need all training data loaded. how to limit this?
# option 1: only load recent posts. bring domain knowledge to it. we know
#           some tech has a shelf life.
# option 2: build an index that we can use to narrow the space.
#           tag vs. words example. we'd need the dictionary in memory.
#           put the tag to post id index in redis.
#           look up the post ids for tags that match on words.
#           fetch those posts and run knn on them vs the unknown.
# refinement: order the tag to post id index by post popularity/time
#             only look at the 100 posts close. still needs to be fast.
#             probably want an evented server, plus threads for the calcs.
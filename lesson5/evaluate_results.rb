
# all tags will be {post_id => tags}
id_to_observed_tags = read_post_tags("post_tags.txt")
model1_id_to_predicted_tags = read_post_tags("m1_tags.txt")
model2_id_to_predicted_tags = read_post_tags("m2_tags.txt")

m1_correct = 0
m2_correct = 0
m1_over_m2 = 0
m2_over_m1 = 0

observed_tags.each_pair do |id, tags|
  m1_predicted_tags = model1_id_to_predicted_tags[id]
  m2_predicted_tags = model2_id_to_predicted_tags[id]
end

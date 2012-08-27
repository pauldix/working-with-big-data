require 'rubygems'
require 'cassandra'

db = Cassandra.new('big_data', '127.0.0.1:9160')

# get a specific user's tags
row = db.get(:user_tags, "paul")

def tag_counts_from_row(row)
  tags = {}

  row.each_pair do |pair|
    column, tag_count = pair
    tag_name = column.parts.first

    tags[tag_name] = tag_count
  end

  tags
end

# insert a new user
db.add(:user_tags, "todd", 3, "postgres")

tags = tag_counts_from_row(row)
puts "paul - #{tags.inspect}"

# output everyone's tags
user_ids = []
db.get_range(:user_tags, :batch_size => 10000) do |id|
  user_ids << id
end

rows_with_ids = db.multi_get(:user_tags, user_ids)
rows_with_ids.each do |row_with_id|
  name, row = row_with_id

  tags = tag_counts_from_row(row)
  puts "#{name} - #{tags.inspect}"
end

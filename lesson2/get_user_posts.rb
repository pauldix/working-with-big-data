require 'rubygems'
require 'cassandra'

db = Cassandra.new('big_data', '127.0.0.1:9160')

user_ids = []
db.get_range(:user_post_activity, :batch_size => 10000) do |id|
  user_ids << id
end

rows_with_ids = db.multi_get(:user_post_activity, user_ids)

rows_with_ids.each do |row_with_id|
  user_id, columns = row_with_id

  puts "user_id: #{user_id}"
  columns.each do |column|
    cassandra_column, post_id = column
    activity_time = Time.at((cassandra_column.to_i >> 12) / 1_000_000)
    puts "#{post_id} at #{activity_time}"
  end
  puts "***************"
end

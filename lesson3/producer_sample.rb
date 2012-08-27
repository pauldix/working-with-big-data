require 'rubygems'
require 'kafka'
require 'json'

raise "You must specify a number of partitions: ./producer_sample.rb 10" if ARGV.empty?
partition_count = ARGV[0].to_i

producer = Kafka::Producer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data_sample",
  :partition => 0
)

puts "sending on topic #{producer.topic}"
user_ids = [234212, 1337, 1232]
20.times do |iteration|
  user_id = user_ids[iteration % user_ids.size]
  producer.partition = user_id % partition_count
  puts "sending user #{user_id} to partition #{producer.partition}"
  message = Kafka::Message.new({:user_id => user_id, :data => "stuff"}.to_json)
  producer.send(message)
end

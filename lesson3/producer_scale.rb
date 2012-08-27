require 'rubygems'
require 'kafka'

raise "You must specify a number of partitions: ./producer_scale.rb 3" if ARGV.empty?
partition_count = ARGV[0].to_i

producer = Kafka::Producer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data_scale",
  :partition => 0
)

puts "sending on topic #{producer.topic}"
10.times do |iteration|
  producer.partition = rand(partition_count)
  puts "sending to partition #{producer.partition}"
  message = Kafka::Message.new("#{iteration} iterations")
  producer.send(message)
end

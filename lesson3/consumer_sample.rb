require 'rubygems'
require 'kafka'
require 'json'

raise "You must specify a user_id and parition count to consume from: ./consumer_sample.rb 234212 10" if ARGV.empty?
user_id = ARGV[0].to_i
parition_count = ARGV[1].to_i
partition = user_id % parition_count

consumer = Kafka::Consumer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data_sample",
  :partition => partition
)

puts "consuming messages from #{consumer.topic} partition #{partition} of #{parition_count} for user #{user_id}"
consumer.loop do |messages|
  messages.each do |message|
    json = JSON.parse(message.payload)
    if json["user_id"] == user_id
      puts message.payload
    else
      puts "skipping #{json['user_id']}"
    end
  end
end
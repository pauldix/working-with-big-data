require 'rubygems'
require 'kafka'

raise "You must specify a parition to consume from: ./consumer_scale.rb 3" if ARGV.empty?
partition = ARGV[0].to_i

consumer = Kafka::Consumer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data_scale",
  :partition => partition
)

puts "consuming messages from #{consumer.topic} partition #{partition}"
consumer.loop do |messages|
  messages.each do |message|
    puts message.payload
  end
end
require 'rubygems'
require 'kafka'
require 'json'

producer = Kafka::Producer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data_ha",
  :partition => 0
)

puts "sending on topic #{producer.topic}"
10000.times do |iteration|
  puts "sending #{iteration}"
  message = Kafka::Message.new({:id => iteration, :m => "hi"}.to_json)
  producer.send(message)
end

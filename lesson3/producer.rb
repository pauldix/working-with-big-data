require 'rubygems'
require 'kafka'

producer = Kafka::Producer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data",
  :partition => 0
)

puts "sending on topic #{producer.topic}"
10.times do |iteration|
  message = Kafka::Message.new("#{iteration} iterations")
  producer.send(message)
end

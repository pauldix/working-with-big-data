require 'rubygems'
require 'kafka'

consumer = Kafka::Consumer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data",
  :partition => 0
)

consumer.loop do |messages|
  messages.each do |message|
    puts message.payload
  end
end
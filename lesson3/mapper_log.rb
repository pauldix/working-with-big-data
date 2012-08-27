require 'rubygems'
require 'redis'
require 'kafka'

redis = Redis.new(
  :host => "localhost",
  :port => 6379
)

consumer = Kafka::Consumer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data_ha",
  :partition => 0
)

STDIN.each do |line|
  topic, partition = line.split
  partition = partition.to_i

  offset_key = "last_log_offset_#{topic}_#{partition}"

  offset = redis.get(offset_key)
  offset ||= 0
  offset = offset.to_i

  consumer.topic = topic
  consumer.partition = partition
  consumer.partition.offset

  file_name = "#{topic}_#{partition}_#{Time.now.strftime("%Y%M%d%H")}"
  File.open(file_name, "w+")

  messages = consumer.consume

  while !messages.empty?
    messages.each do |message|
      File.puts(message.payload)
    end
    messages = consume.consume
  end

  File.close
  `hadoop dfs -copyFromLocal #{file_name} kafka_logs`
  File.delete(file_name)

  redis.set(offset_key, consumer.offset)
end

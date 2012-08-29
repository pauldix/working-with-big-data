#!/usr/bin/env ruby

require 'rubygems'
require 'kafka'
require 'redis'
require 'json'

redis = Redis.new(
  :host => "localhost",
  :port => 6379
)

consumer = Kafka::Consumer.new(
  :host      => "localhost",
  :port      => 9092,
  :topic     => "big_data_ha",
  :partition => 0,
  :max_size  => 100000
)

consumer_group_name = "big_data_ha_tail"
partition_count = 10

while (true) do
  partition_count.times do |partition|
    partition_processing_lock_key = "#{consumer_group_name}_#{partition}"
    is_processing = redis.setnx(partition_processing_lock_key, 1)
    if is_processing == "1" # it isn't processing by anyone else so let's do it
      last_offset = "#{consumer_group_name}_#{partition}_last_offset"
      redis.expire(partition_processing_lock_key, 2)
      last_offset = redis.get(last_offset_key).to_i

      consumer.offset = last_offset
      messages = consumer.consume

      # do processing

      # kill the lock
      redis.piplined do
        redis.set(last_offset_key, consumer.offset)
        redis.del(partition_processing_lock_key)
      end
    end
  end

  sleep 0.5
end
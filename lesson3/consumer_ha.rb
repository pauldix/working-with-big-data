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
  :partition => 0
)

last_processed_offset = 0
consumer_group_name = "big_data_ha_tail"
processing_queue_name = "big_data_ha_processing"
done_queue_name = "big_data_ha_done"

PROCESS_MESSAGE_SCRIPT = <<-eos
local is_done = redis.call('zscore', KEYS[1], ARGV[2])
if not is_done then
  local is_processing = redis.call('zscore', KEYS[2], ARGV[2])
  if not is_processing then
    redis.call('zadd', KEYS[2], ARGV[1], ARGV[2])
    return 'process'
  end
  return 'processing'
else
  return 'done'
end
eos

MARK_DONE_SCRIPT = <<-eos
redis.call('zadd', KEYS[1], ARGV[1], ARGV[2])
redis.call('zrem', KEYS[2], ARGV[2])
eos

TRIM_CACHE_SCRIPT = <<-eos
local cache_size = redis.call('zcard', KEYS[1])
if (cache_size > ARGV[1]) then
  local trim_to = cache_size - ARGV[1]
  redis.call('zremrange', KEYS[1], 0, trim_to)
end
eos

messages_consumed = 0
MAX_PROCESSED_CACHE_SIZE = 50000

consumer.loop do |messages|
  messages.each do |message|
    json = JSON.parse(message.payload)
    id = json["id"]
    time = Time.now.to_i

    return_val = redis.eval(
      PROCESS_MESSAGE_SCRIPT,
      {
        :keys => [done_queue_name, processing_queue_name],
        :argv => [time, id]
      }
    )

    puts "#{id} is #{return_val}"

    if return_val == "process"
      redis.eval(
        MARK_DONE_SCRIPT,
        {
          :keys => [done_queue_name, processing_queue_name],
          :argv => [time, id]
        }
      )
    elsif return_val == "processing"
      # save this and check on it later
    end

    messages_consumed += 1
    if messages_consumed % MAX_PROCESSED_CACHE_SIZE == 0
      redis.eval(
        TRIM_CACHE_SCRIPT,
        {
          :keys => [done_queue_name],
          :argv => [MAX_PROCESSED_CACHE_SIZE]
        }
      )
    end
  end
end

#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'cassandra-cql'

db = CassandraCQL::Database.new('127.0.0.1:9160', {:keyspace => 'big_data'})

STDIN.each do |line|
  puts line
  puts line.index("\t")
  json = line.slice(line.index(/\s/) + 1, line.length).strip
  puts json.inspect
  post = JSON.parse(json)
  puts post["id"]
  puts post["title"]
  puts post["body"]
  puts post["post_type"]
  puts post["tags"]
  puts post["owner_id"]
  puts post["created_date"]

  db.execute("INSERT INTO posts (post_id, title, body, post_type, tags, owner_id, created_date) VALUES (?, ?, ?, ?, ?, ?, ?)",
    post["id"],
    post["title"],
    post["body"],
    post["post_type"],
    post["tags"],
    post["owner_id"],
    post["created_date"]
  )
end

#!/usr/bin/env ruby

require 'date'
require 'rubygems'
require 'cassandra-cql'
require 'cassandra'

db = Cassandra.new('big_data', '127.0.0.1:9160')

# db = CassandraCQL::Database.new('127.0.0.1:9160', {:keyspace => 'big_data'})

STDIN.each do |line|
  parent_match = line.match(/\sParentId="(.*?")/)
  if parent_match
    post_id = parent_match[1].chomp('"')
  else
    match = line.match(/\sId="(.*?")/)
    post_id = match[1].chomp('"') if match
  end

  if post_id
    # TODO: add this in or take it out
    is_question = line.index('PostTypeId="1"')
    activity_type = is_question ? 1 : 2
    # end

    user_match = line.match(/\sOwnerUserId="(.*?")/)
    creation_time_match = line.match(/\sCreationDate="(.*?")/)

    if creation_time_match && user_match
      user_id = user_match[1].chomp('"')

      creation_time_string = creation_time_match[1].chomp('"')
      creation_time = DateTime.parse(creation_time_string).to_time

      db.insert(:user_post_activity, user_id, {creation_time => post_id})
      # db.execute("UPDATE user_post_activity2 SET 'activity_type'=? WHERE 'user_id'=? AND 'time'=? AND 'post_id'=?",
      #   activity_type, user_id, creation_time_string, post_id)
      # db.execute("UPDATE user_post_activity2 SET 'time'=?, 'post_id'=?, 'activity_type'=? WHERE 'user_id'=?",
      #   creation_time_string, post_id, activity_type, user_id)
      # db.execute("INSERT INTO user_post_activity2 ('user_id', 'time', 'post_id', 'activity_type') VALUES (?, ?, ?, ?)",
      #   user_id, creation_time_string, post_id, activity_type)
      puts "User #{user_id} on post #{post_id} at #{creation_time}"
    else
      puts "****************************"
    end
  end
end

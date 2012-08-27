#!/usr/bin/env ruby

require 'json'
require 'date'

def extract_post_info(line)
  match = line.match(/\sId="(.*?")/)
  unless match
    return nil
  end

  post_id = match[1].chomp('"')

  owner_match = line.match(/OwnerUserId="(.*?")/)
  owner_id = owner_match ? match[1].chomp('"') : ""

  title_match = line.match(/Title=(".*?")/)
  body_match = line.match(/Body="(.*?")/)

  title = title_match ? title_match[1] : ""
  body  = body_match ? body_match[1] : ""

  tags_match = line.match(/Tags=(".*?")/)
  if tags_match
    tags = tags_match[0].downcase
    tags = tags.split("&gt;").map {|s| s.gsub(/.*\&lt\;/, '')}
    tags = tags.slice(0, tags.length - 2)
  else
    tags = []
  end

  creation_date_match = line.match(/\sCreationDate="(.*?")/)

  if creation_date_match
    creation_string = creation_date_match[1].chomp('"')
    created_date = DateTime.parse(creation_string).to_time
  else
    created_date =Time.now
  end

  post_type = is_question?(line) ? "1" : "2"

  {
    :id   => post_id,
    :title     => title,
    :body      => body,
    :post_type => post_type,
    :owner_id  => owner_id,
    :tags      => tags.join(","),
    :created_date => created_date
  }
end

def is_question?(string)
  string.index('PostTypeId="1"')
end

STDIN.each do |line|
  post = extract_post_info(line)
  puts "#{rand(10)}\t#{post.to_json}" if post
end

#!/usr/bin/env ruby

require "#{File.dirname(__FILE__)}/post_parser.rb"

STDIN.each do |line|
  post = PostParser.from_xml_fragment(line)

  if post
    post[:tags].each do |tag|
      puts "#{tag}\t1\t#{post[:created_date].to_i}"
    end
  end
end

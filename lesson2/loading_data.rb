require "rubygems"
require "bundler/setup"
require 'open-uri'
require 'awesome_print'
require 'json'
require 'readability'

# source = open('http://www.nytimes.com/2012/08/19/business/lawyers-of-big-tobacco-lawsuits-take-aim-at-food-industry.html').read
# puts Readability::Document.new(source).content

class HackerNewsApi
  @base_items_url = "http://api.thriftdb.com/api.hnsearch.com/items/_search?sortby=create_ts%20desc&filter[fields][type]=submission&"

  def self.search(options)
    url = @base_items_url.dup
    url << "q=#{options[:query]}"
    url << "&filter[fields][domain]=#{options[:domain]}" if options.has_key?(:domain)
    url << "&limit=#{options[:limit]}" if options.has_key?(:limit)
    url << "&start=#{options[:start]}" if options.has_key?(:start)

    json = JSON.parse(open(url).read)
    ap json

    json["results"].each do |result|
      url = result["item"]["url"]
      if url
        raw_content = open(url).read
        puts Readability::Document.new(raw_content).content
      end
    end
  end
end

HackerNewsApi.search({:query => "facebook"})
require 'rubygems'
require 'sinatra'

get '/*' do
  file_name  = params[:splat].first
  file_parts = file_name.split("/")

  puts "GET: #{file_name}"

  if File.exists?(file_name)
    File.read(file_name)
  elsif file_parts.first == "tags"
    tag_name = file_parts.last.split(".").first
    `grep \\"#{tag_name}\\" tags_by_week.txt`
  else
    [404, "#{file_name} not found\n"]
  end
end

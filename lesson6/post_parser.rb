require 'date'

class PostParser
  def self.from_xml_fragment(line)
    match = line.match(/\sId="(.*?")/)
    unless match
      return nil
    end

    tags_match = line.match(/Tags=(".*?")/)
    if tags_match
      tags = tags_match[0].downcase
      tags = tags.split("&gt;").map {|s| s.gsub(/.*\&lt\;/, '')}
      tags = tags.slice(0, tags.length - 2)
    end
    tags ||= []

    creation_date_match = line.match(/\sCreationDate="(.*?")/)

    if creation_date_match
      creation_string = creation_date_match[1].chomp('"')
      created_date = DateTime.parse(creation_string).to_time
    else
      created_date =Time.now
    end
    {
      :tags      => tags,
      :created_date => created_date
    }
  end

  def self.clean_string(string)
    string.gsub('"', ' ')
          .gsub("&lt;p&gt;", '')
          .gsub("&lt;", ' ')
          .gsub("&gt;", ' ')
          .gsub("/p &#xA;", '')
          .gsub("&#xA;", '')
          .gsub(/\d/, '')
          .gsub(/[^\w]/, ' ')
          .downcase
          .split
          .join(' ')
  end
end

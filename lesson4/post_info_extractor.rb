def clean_string(string)
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

def extract_post_info(line)
  match = line.match(/\sId="(.*?")/)
  post_id = match[1].chomp('"') if match

  # this is the ghetto way we're going to pull the tags out of this string
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

  [post_id, clean_string(title), clean_string(body), tags]
end

def is_question?(string)
  string.index('PostTypeId="1"')
end

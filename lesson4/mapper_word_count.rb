#!/usr/bin/env ruby

def clean_string(string)
  string.gsub('"', ' ')
        .gsub("&lt;p&gt;", '')
        .gsub("&lt;", ' ')
        .gsub("&gt;", ' ')
        .gsub("/p &#xA;", '')
        .gsub("&#xA;", '')
        .gsub(/\d/, '')
        .gsub(/[^\w]/, ' ')
end

def add_word_counts(string, word_counts)
  words = clean_string(string).downcase.split
  words.each do |word|
    word_counts[word] += 1
  end
end

STDIN.each do |line|
  # only look at tags for posts, not questions
  if line.index('PostTypeId="1"')

    word_counts = Hash.new {|h, k| h[k] = 0}

    # this is the ghetto way we're going to pull the tags out of this string
    title_match = line.match(/Title=(".*?")/)
    body_match = line.match(/Body="(.*?")/)

    if title_match
      add_word_counts(title_match[1], word_counts)
    end

    if body_match
      add_word_counts(body_match[1], word_counts)
    end

    word_counts.each_pair do |word, count|
      puts "#{word}\t#{count}"
    end
  end
end

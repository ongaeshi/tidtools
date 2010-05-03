# -*- coding: utf-8 -*-

require 'parsedate'

class Tweet
  attr_reader :time_stamp, :content

  def initialize(time_stamp, content)
    @time_stamp = time_stamp
    @content = content
  end

  # つぶやき形式の文字列を渡すと、Tweet型の配列を返す
  def self.parse_from_text(text)
    tweets = []
    array = text.split("\n")

    index = 0
    start_index = 0
    is_pre = false
    
    while true
      if (array[index] =~ /^\{\{\{/)
        is_pre = true
      end
      
      if (!is_pre and array[index] =~ /^----+/)
        text = array[start_index...index].join("\n")
        tweets.push Tweet.new(parse_time_stamp(text), text)
        start_index = index + 1
      end
      
      if (array[index] =~ /^\}\}\}/)
        is_pre = false
      end

      index += 1

      break if (index >= array.size)
    end
      
    tweets
  end

  def self.parse_time_stamp(text)
    str = text.split(/\n/)[-1]

    if (str)
      ary = ParseDate::parsedate(str)
      if (ary[0])
        Time::local(*ary[0..4])
      else
        nil
      end
    else
      nil
    end
  end
end

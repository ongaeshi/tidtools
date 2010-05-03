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

    text.split(/^----+\n/).each do |elem|
      # 文字列終端の----をカット(一番最後に残る可能性がある)
      elem = elem.sub(/^----+\n?\Z/, "")
      
      # つぶやきの作成
      tweets.push Tweet.new(parse_time_stamp(elem), elem)
    end

    tweets
  end

  def self.parse_time_stamp(text)
    str = text.split(/\n/)[-1]

    if (str)
      ary = ParseDate::parsedate(str)
#      p ary
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

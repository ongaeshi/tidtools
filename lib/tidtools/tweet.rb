# -*- coding: utf-8 -*-

require 'parsedate'

class Tweet
  attr_reader :time_stamp, :content

  def initialize(time_stamp, content)
    @time_stamp = time_stamp
    @content = content
  end
  
  # テキストをつぶやき形式に整形する
  def self.decorate(text)
    array = text.split("\n")

    array.each_with_index do |line, index|
      # 5つ以上の水平線を4つにそろえる
      array[index] = array[index].sub(/^----+$/, "----")

      # 水平線手前の日付表示に装飾を付ける
      if (line =~ /^----+$/ and index > 0)
        ary = ParseDate::parsedate(array[index - 1])
        if (ary[0])           # 日付表示の場合のみ
          array[index - 1] = "~~@@color(gray):" + array[index - 1] + "@@~~"
        end
      end
    end

    array.join("\n")
  end

  # つぶやき形式のテキストをマージする
  def self.merge(origin, add)
    origin_t = Tweet.parse_from_text(origin)
    add_t = Tweet.parse_from_text(add)

    add_t.each do |tweet|
      origin_t.insert(find_insert_pos(origin_t, tweet), tweet)
    end

    origin_t
  end

  # ソートされたつぶやきの配列に対して、あるつぶやきの挿入位置を返す
  def self.find_insert_pos(tweets, tweet)
    return 0 if tweet.time_stamp.nil?
    
    tweets.each_index do |index|
      if (tweets[index].time_stamp.nil?)
        next
      elsif (tweet.time_stamp >= tweets[index].time_stamp)
        return index
      end
    end

    return tweets.size
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

      if (index >= array.size)
        if (index > start_index)
          text = array[start_index..index].join("\n")
          tweets.push Tweet.new(parse_time_stamp(text), text)
        end

        break
      end
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

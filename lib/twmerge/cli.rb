# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../tidtools/tiddle')
require File.join(File.dirname(__FILE__), '../tidtools/tweet')
require 'optparse'

module Twmerge
  class CLI
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new('twmerge origin_file add_file')
      opt.parse!(arguments)

      # マージ元ファイルを取得
      origin = nil              # マージ元ファイル
      open(arguments[0]) do |file|
        origin = file.read
      end

      # マージするファイルを取得
      merge = nil
      open(arguments[1]) do |file|
        merge = file.read.split("\n")
      end

      merge.each_with_index do |line, index|
        # 5つ以上の水平線を4つにそろえる
        merge[index] = merge[index].sub(/^----+$/, "----")

        # 水平線手前の日付表示に装飾を付ける
        if (line =~ /^----+$/ and index > 0)
          ary = ParseDate::parsedate(merge[index - 1])
          if (ary[0])           # 日付表示の場合のみ
            merge[index - 1] = "~~@@color(gray):" + merge[index - 1] + "@@~~"
          end
        end
      end

      # マージ
      tweets = Tweet.merge(origin, merge.join("\n"))

      # 結果を表示
      tweets.each do |elem|
        puts elem.content, "----"
      end
    end
  end
end

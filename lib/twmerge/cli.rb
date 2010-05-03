# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../tidtools/tiddle')
require File.join(File.dirname(__FILE__), '../tidtools/tweet')
require 'optparse'

module Twmerge
  class CLI
    def self.execute(stdout, arguments=[])
      file_name = ENV['TIDGREP_PATH']
      title = "Tweet - New"
        
      opt = OptionParser.new('twmerge merge_file')
      opt.on('-f FILE_NAME', '--filename FILE_NAME', 'TiddlyWiki file name') {|v| file_name = v }
      opt.on('-t TITLE', '--title TITLE', 'origin tiddle title') {|v| title = v }
      opt.parse!(arguments)

      # マージ元ファイルを取得
      tiddles = Tiddle.parse(file_name)
      origin = nil              # マージ元ファイル

      tiddles.each do |tiddle|
        if (tiddle.title == title) # 正規表現じゃないよ
          origin = tiddle.content
          break
        end
      end

      # マージするファイルを取得
      merge = nil
      open(arguments[0]) do |file|
        merge = file.read.split("\n")
      end

      merge.each_with_index do |line, index|
        # 5つ以上の水平線を4つにそろえる
        merge[index] = merge[index].sub(/^----+$/, "----")

        # 水平線手前の日付表示に装飾を付ける
        if (line =~ /^----+$/ and index > 0)
          merge[index - 1] = "~~@@color(gray):" + merge[index - 1] + "@@~~"
        end
      end

      # つぶやきに変換
      tweets = Tweet.parse_from_text(origin)
      tweets += Tweet.parse_from_text(merge.join("\n"))

      # 日付順にソート
      tweets = tweets.sort {|a, b|
        # 日付の書いていないつぶやきは先頭に移動させ、早い段階で問題を見つけられるようにする
        if (a.time_stamp.nil? and b.time_stamp.nil?)
          0
        elsif (b.time_stamp.nil?)
          -1
        elsif (a.time_stamp.nil?)
          1
        else
          a.time_stamp <=> b.time_stamp
        end
      }.reverse

      # テスト表示
      tweets.each do |elem|
        puts elem.time_stamp, elem.content, "----"
      end
    end
  end
end

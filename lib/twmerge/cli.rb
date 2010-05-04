# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../tidtools/tiddle')
require File.join(File.dirname(__FILE__), '../tidtools/tweet')
require 'optparse'

module Twmerge
  class CLI
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new('twmerge origin_file add_file')
      opt.parse!(arguments)

      if (arguments.size != 2)
        puts opt.help
        exit
      end
      
      # テキストを取得
      origin = open(arguments[0]).read
      add = Tweet.decorate(open(arguments[1]).read)
      
      # マージ
      tweets = Tweet.merge(origin, add)

      # 結果を表示
      tweets.each do |elem|
        puts elem.content, "----"
      end
    end
  end
end

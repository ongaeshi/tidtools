# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../tidtools/tiddle')
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

      tiddles = Tiddle.parse(file_name)
      origin = nil              # マージ元ファイル

      tiddles.each do |tiddle|
        if (tiddle.title == title) # 正規表現じゃないよ
          origin = tiddle.content
          break
        end
      end

      print origin
    end
  end
end

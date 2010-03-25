#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'hpricot'
require 'optparse'

class Tiddle
  attr_reader :title, :created, :modified, :tags, :changecount, :content
  
  def initialize(title, created, modified, tags, changecount, content)
    @title = title
    @created = created
    @modified = modified
    @tags = tags
    @changecount = changecount
    @content = content
  end
  
  # TiddlyWikiのファイルを渡すと、Tiddleの配列を返す
  def self.parse(file_name)
    tiddles = []

    doc = Hpricot(open(file_name).read())

    doc.search("div").each do |elem|
      if (elem['id'] == 'storeArea')
        elem.search("div").each do |tiddle|
          tiddles.push(Tiddle.new(title(tiddle),
                                  tiddle['created'],
                                  tiddle['modified'],
                                  tiddle['tags'],
                                  tiddle['changecount'],
                                  content(tiddle)))
        end
      end
    end

    return tiddles
  end

  # tiddleのタイトルを取得
  def self.title(tiddle)
    tiddle['title'] || tiddle['tiddler']
  end

  # tiddleの内容を取得
  def self.content(tiddle)
    pre = tiddle.search("pre")

    if (pre.size > 0)
      pre.inner_html
    else
      tiddle.inner_html
    end
  end
end

title = nil
regexp_option = 0
file_name = nil
report = false

opt = OptionParser.new('tidgrep [option] keyword')
opt.on('-f FILE_NAME', '--filename FILE_NAME', 'TiddlyWiki file name') {|v| file_name = v }
opt.on('-t TITLE', '--title TITLE', 'match title') {|v| title = v }
opt.on('-i', '--ignore', 'ignore case') {|v| regexp_option |= Regexp::IGNORECASE }
opt.on('-r', '--report', 'disp report') {|v| report = true }
opt.parse!

if (!file_name || ARGV.size != 1)
  puts opt.help
  exit
end

tiddles = Tiddle.parse(file_name)
match_lines = 0
total_lines = 0
match_tiddles = 0

title_regexp = title && Regexp.new(title, regexp_option)
content_regexp = ARGV[0] && Regexp.new(ARGV[0], regexp_option)

tiddles.each do |tiddle|
  next if (title && tiddle.title !~ title_regexp)
  is_match_tiddle = false
  line_no = 1
  tiddle.content.each_line do |line|
    if (content_regexp =~ line)
      puts "#{tiddle.title}:#{line_no}:#{line}"
      match_lines += 1
      unless is_match_tiddle
        match_tiddles += 1
        is_match_tiddle = true
      end
    end
    line_no += 1
    total_lines += 1
  end
end

if (report)
  puts "-----------------------------"
  puts "match lines : #{match_lines}"
  puts "total lines : #{total_lines}"
  puts "match tiddles : #{match_tiddles}"
  puts "total tiddles : #{tiddles.size}"
end

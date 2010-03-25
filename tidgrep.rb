#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'hpricot'

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
          tiddles.push(Tiddle.new(tiddle['title'],
                                  tiddle['created'],
                                  tiddle['modified'],
                                  tiddle['tags'],
                                  tiddle['changecount'],
                                  tiddle.search("pre").inner_html))
        end
      end
    end

    return tiddles
  end
end

tiddles = Tiddle.parse("#{ARGV[0]}")
match_lines = 0
total_lines = 0
match_tiddles = 0

tiddles.each do |tiddle|
  is_match_tiddle = false
  line_no = 1
  tiddle.content.each_line do |line|
    if (/#{ARGV[1]}/ =~ line)
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

puts "match lines : #{match_lines}"
puts "total lines : #{total_lines}"

puts "match tiddles : #{match_tiddles}"
puts "total tiddles : #{tiddles.size}"


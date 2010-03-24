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
matches = 0
total_lines = 0

tiddles.each do |tiddle|
  line_no = 1
  tiddle.content.each_line do |line|
    if (/#{ARGV[1]}/ =~ line)
      puts "#{tiddle.title}:#{line_no}:#{line}"
      matches += 1
    end
    line_no += 1
    total_lines += 1
  end
end

puts "matches : #{matches}"
puts "total lines : #{total_lines}"
puts "total tiddles : #{tiddles.size}"


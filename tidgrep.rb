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

tiddles = Tiddle.parse("/Users/ongaeshi/Dropbox/memo/memo.html")

puts tiddles[0].title
puts tiddles[0].created
puts tiddles[0].content.grep(/Flash/)

p tiddles.size
# tiddles.each {|tiddle| p tiddle}

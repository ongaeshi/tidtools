# -*- coding: utf-8 -*-

require 'rubygems'
require 'hpricot'
require 'parsedate'

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
                                  convtime(tiddle['created']),
                                  convtime(tiddle['modified']),
                                  tiddle['tags'],
                                  tiddle['changecount'],
                                  content(tiddle)))

#          print tiddle['modified'], '=>', tiddles.last.modified, "\n"
        end
      end
    end

    return tiddles
  end

  def self.parse_sort_modified(file_name)
    parse(file_name).sort {|a, b|
      if (b.modified.nil?)
        -1
      elsif (a.modified.nil?)
        1
      else
        a.modified <=> b.modified
      end
    }.reverse
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

  # 時刻に変換
  def self.convtime(str)
    if (str)
      ary = ParseDate::parsedate(str)
      Time::local(*ary[0..4])
    else
      nil
    end
  end
end


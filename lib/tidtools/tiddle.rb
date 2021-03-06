# -*- coding: utf-8 -*-

require 'rubygems'
require 'hpricot'
require File.join(File.dirname(__FILE__), '../tidtools/platform')
if Platform.ruby19?
  require 'date'
else
  require 'parsedate'
end

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

          # print tiddle['modified'], '=>', tiddles.last.modified, "\n"
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
    data = content1(tiddle)
    data.gsub!(/\\n/, "\n")
    data
  end

  # tiddleの内容を取得(処理1 HTMLから取り出し)
  def self.content1(tiddle)
    pre = tiddle.search("pre")

    if (pre.size > 0)
      pre.inner_html
    else
      tiddle.inner_html
    end
  end
  private_class_method :content1

  # 時刻に変換
  #   1.9の場合はDateTimeを、1.8.7の場合はTimeを返す
  def self.convtime(str)
    if (str)
      if Platform.ruby19?
        DateTime.parse(str)
      else
        ary = ParseDate::parsedate(str)
        Time::local(*ary[0..4])
      end
    else
      nil
    end
  end
end


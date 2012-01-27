# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/01/27

require 'rubygems'
require 'tidtools/tiddle'
require 'fileutils'
require 'kconv'

module Tidtools
  module Tiddler2texts
    module_function

    def escape(src)
      r = src
      r.gsub!(/\//, "／")
      r.gsub!(/:/, "：")
      r.gsub!(/>/, "＞")
      r.gsub!(/"/, "”")
      r
    end

    def output(filename, output_dir)
      filename = File.expand_path filename
      
      FileUtils.mkdir_p output_dir

      data = Tiddle.parse(filename)

      data.each do |tiddler|
        # OSX
        filename = output_dir + '/' + escape(tiddler.title)
        # win
        # filename = output_dir + '/' + escape(tiddler.title.kconv(Kconv::SJIS))

        next if (File.exist?(filename) and File.read(filename) == tiddler.content)
        
        open(filename, 'w') do |f|
          puts "#{filename}"
          f.write tiddler.content
        end
      end
    end
  end
end



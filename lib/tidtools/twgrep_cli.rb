# -*- coding: utf-8 -*-
require 'tidtools/tidgrep'
require 'optparse'

module Tidtools
  class TwgrepCli
    def self.execute(stdout, arguments=[])
      file_names = ENV['TIDDLYWIKI_PATHS'].split(";")
      file_no = 0
      title = "Tweet"
      regexp_option = 0
      report = false 
      match_rule = "tweet"
      is_comp = false
      kcode = Platform.get_shell_kcode
      
      opt = OptionParser.new('twgrep [option] keyword')
      opt.on('-f TIDDLYWIKI_PATHS', '--filename TIDDLYWIKI_PATHS', 'TiddlyWiki path names') {|v| file_names = v.split }
      opt.on('-n SELECT_NO', '--fileno SELECT_NO', 'file select number. (0 is all. 1,2,3,4.. is select only one.)') {|v| file_no = v.to_i }
      opt.on('-t TITLE', '--title TITLE', 'match title') {|v| title = v }
      opt.on('-i', '--ignore', 'ignore case') {|v| regexp_option |= Regexp::IGNORECASE }
      opt.on('-r', '--report', 'disp report') {|v| report = true }
      opt.on('-c', '--comp', 'compression disp') {|v| is_comp = true; report = true }
      opt.parse!(arguments)

      obj = Tidgrep.new(stdout,
                                 file_names,
                                 file_no,
                                 title,
                                 regexp_option,
                                 report,
                                 match_rule,
                                 is_comp,
                                 arguments,
                                 kcode)

      if obj.validOption? && arguments.size > 0
        obj.execute
      else
        stdout.puts opt.help
      end
    end
  end
end

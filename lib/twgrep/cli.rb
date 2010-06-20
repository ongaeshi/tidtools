# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../tidgrep/cli')
require 'optparse'

module Twgrep
  class CLI
    def self.execute(stdout, arguments=[])
      file_name = ENV['TIDDLYWIKI_PATH']
      title = "Tweet"
      regexp_option = 0
      report = false 
      match_rule = "tweet"
      is_comp = false
      kcode = Platform.get_shell_kcode
      
      opt = OptionParser.new('twgrep [option] keyword')
      opt.on('-f FILE_NAME', '--filename FILE_NAME', 'TiddlyWiki file name') {|v| file_name = v }
      opt.on('-i', '--ignore', 'ignore case') {|v| regexp_option |= Regexp::IGNORECASE }
      opt.on('-r', '--report', 'disp report') {|v| report = true }
      opt.on('-c', '--comp', 'compression disp') {|v| is_comp = true; report = true }
      opt.parse!(arguments)

      obj = Tidgrep::Tidgrep.new(stdout,
                                 file_name,
                                 title,
                                 regexp_option,
                                 report,
                                 match_rule,
                                 is_comp,
                                 arguments,
                                 kcode)

      unless obj.validOption? && arguments.size > 0
        puts opt.help
        exit
      end
      
      obj.execute
    end
  end
end

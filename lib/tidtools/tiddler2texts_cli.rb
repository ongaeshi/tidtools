# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/01/27

require 'tidtools/tiddler2texts'
require 'optparse'

module Tidtools
  class Tiddler2textsCli
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new("#{File.basename($0)} tiddlywiki.html output_dir")
      opt.parse!(arguments)

      if arguments.size == 2
        Tiddler2texts.output(arguments[0], arguments[1])
      else
        stdout.puts opt.help
      end
    end
  end
end

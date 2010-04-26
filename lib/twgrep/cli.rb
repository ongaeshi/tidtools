# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../tidgrep/cli')
require 'optparse'

module Twgrep
  class CLI
    def self.execute(stdout, arguments=[])
      arguments += ["-m", "tweet", "-t", "Tweet"]
      Tidgrep::Tidgrep.new.execute(stdout, arguments)
    end
  end
end

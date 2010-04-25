require File.join(File.dirname(__FILE__), '../tidtools/tiddle')
require 'optparse'

module Tidgrep
  class Tidgrep
    def initialize
    end

    def isValidOption(file_name, title, keyword)
      return false if !file_name
      return title || keyword
    end

    def execute(stdout, arguments=[])
      title = nil
      regexp_option = 0
      file_name = ENV['TIDGREP_PATH']
      report = false
      match_rule = "grep"

      opt = OptionParser.new('tidgrep [option] keyword')
      opt.on('-f FILE_NAME', '--filename FILE_NAME', 'TiddlyWiki file name') {|v| file_name = v }
      opt.on('-t TITLE', '--title TITLE', 'match title') {|v| title = v }
      opt.on('-i', '--ignore', 'ignore case') {|v| regexp_option |= Regexp::IGNORECASE }
      opt.on('-r', '--report', 'disp report') {|v| report = true }
      opt.on('-m MATCH_RULE', '--match MATCH_RULE', 'match rule [grep, tiddle, hr]') {|v| match_rule = v; p match_rule }
      opt.parse!(arguments)

      keyword = arguments[0]

      if (!isValidOption(file_name, title, keyword))
        puts opt.help
        exit
      end

      tiddles = Tiddle.parse_sort_modified(file_name)
      match_lines = 0
      total_lines = 0
      match_tiddles = 0

      title_regexp = title && Regexp.new(title, regexp_option)
      content_regexp = keyword && Regexp.new(keyword, regexp_option)

      tiddles.each do |tiddle|
        next if (title && tiddle.title !~ title_regexp)
        is_match_tiddle = false
        line_no = 1

        if (content_regexp)
          tiddle.content.each_line do |line|
#          tiddle.content.split(/----/).each do |line|
            if (content_regexp =~ line)
              case match_rule
              when "grep"
                puts "#{tiddle.title}:#{line_no}:#{line}"
#                print "#{line}"               
#                print "----"
                match_lines += 1
                unless is_match_tiddle
                  match_tiddles += 1
                  is_match_tiddle = true
                end
              when "tiddle"
                match_lines += 1
                unless is_match_tiddle
                  puts "--- #{tiddle.title} --------------------"
                  match_tiddles += 1
                  is_match_tiddle = true
                end
                puts "#{line}"
              when "hr"
                print "#{line}"               
                print "----"
              end
            end
            line_no += 1
            total_lines += 1
          end
        else
          puts tiddle.title
          match_tiddles += 1
          is_match_tiddle = true
        end

      end

      if (report)
        puts "------------------------------"
        if (content_regexp)
          puts "match lines : #{match_lines}"
          puts "total lines : #{total_lines}"
        end
        puts "match tiddles : #{match_tiddles}"
        puts "total tiddles : #{tiddles.size}"
      end
    end
  end

  class CLI
    def self.execute(stdout, arguments=[])
      Tidgrep.new.execute(stdout, arguments)
    end
  end
end

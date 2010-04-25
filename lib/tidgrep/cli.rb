# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../tidtools/tiddle')
require 'optparse'

module Tidgrep
  class Tidgrep
    def initialize
      @file_name = ENV['TIDGREP_PATH']
      @title = nil
      @regexp_option = 0
      @report = false
      @match_rule = "line"
    end

    def setupParam(stdout, arguments)
      opt = OptionParser.new('tidgrep [option] keyword')
      opt.on('-f FILE_NAME', '--filename FILE_NAME', 'TiddlyWiki file name') {|v| @file_name = v }
      opt.on('-t TITLE', '--title TITLE', 'match title') {|v| @title = v }
      opt.on('-i', '--ignore', 'ignore case') {|v| @regexp_option |= Regexp::IGNORECASE }
      opt.on('-r', '--report', 'disp report') {|v| @report = true }
      opt.on('-m MATCH_RULE', '--match MATCH_RULE', 'match rule [line, tiddle, hr]') {|v| @match_rule = v }
      opt.parse!(arguments)
      
      @keyword = arguments[0]
      @title_regexp = @title && Regexp.new(@title, @regexp_option)
      @content_regexp = @keyword && Regexp.new(@keyword, @regexp_option)

      unless validOption?
        puts opt.help
        exit
      end
    end

    def validOption?
      return false if !@file_name
      return @title || @keyword
    end

    def match_line
      tiddles = Tiddle.parse_sort_modified(@file_name)

      match_lines = 0
      search_lines = 0
      match_tiddles = 0

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)
        is_match_tiddle = false
        line_no = 1

        tiddle.content.each_line do |line|
          if (@content_regexp =~ line)
            puts "#{tiddle.title}:#{line_no}:#{line}"
            match_lines += 1
            unless is_match_tiddle
              match_tiddles += 1
              is_match_tiddle = true
            end
          end
          line_no += 1
          search_lines += 1
        end
      end

      if (@report)
        puts "------------------------------"
        puts "search lines : #{search_lines}"
        puts "match lines : #{match_lines}"
        puts "total tiddles : #{tiddles.size}"
        puts "match tiddles : #{match_tiddles}"
      end
    end

    def match_only_title
      tiddles = Tiddle.parse_sort_modified(@file_name)

      match_tiddles = 0

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)
        puts tiddle.title
        match_tiddles += 1
      end

      if (@report)
        puts "------------------------------"
        puts "total tiddles : #{tiddles.size}"
        puts "match tiddles : #{match_tiddles}"
      end
    end

    def match_tiddle
      tiddles = Tiddle.parse_sort_modified(@file_name)

      search_tiddles = 0
      match_tiddles = 0

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)
        search_tiddles += 1

        if (@content_regexp =~ tiddle.content)
          match_tiddles += 1
          puts "--- #{tiddle.title} --------------------"
          puts tiddle.content
        end
      end

      if (@report)
        puts "------------------------------"
        puts "total tiddles : #{tiddles.size}"
        puts "search tiddles : #{search_tiddles}"
        puts "match tiddles : #{match_tiddles}"
      end
    end

    def match_hr
      tiddles = Tiddle.parse_sort_modified(@file_name)

      search_tweets = 0
      match_tweets = 0

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)
        is_match_tiddle = false

        tweets = tiddle.content.split(/^----+\n/)
        search_tweets += tweets.size

        tweets.each do |tweet|
          if (@content_regexp =~ tweet)
            match_tweets += 1
            unless is_match_tiddle
              puts "--- #{tiddle.title} --------------------"
              is_match_tiddle = true
            else
              puts "----\n"
            end
            print "#{tweet}"
          end
        end
      end

      if (@report)
        puts "------------------------------"
        puts "search tweets : #{search_tweets}"
        puts "match tweets : #{match_tweets}"
      end
    end

    def execute(stdout, arguments=[])
      # パラメータの設定
      setupParam(stdout, arguments)
      
      # マッチルールごとに処理を変える
      if (@content_regexp) 
        case @match_rule
        when "line"
          match_line
        when "tiddle"
          match_tiddle
        when "hr"
          match_hr
        end
      else
        match_only_title
      end
    end

  end

  class CLI
    def self.execute(stdout, arguments=[])
      Tidgrep.new.execute(stdout, arguments)
    end
  end
end

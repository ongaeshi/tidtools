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
      @is_comp = false
    end

    def setupParam(stdout, arguments)
      opt = OptionParser.new('tidgrep [option] keyword')
      opt.on('-f FILE_NAME', '--filename FILE_NAME', 'TiddlyWiki file name') {|v| @file_name = v }
      opt.on('-t TITLE', '--title TITLE', 'match title') {|v| @title = v }
      opt.on('-i', '--ignore', 'ignore case') {|v| @regexp_option |= Regexp::IGNORECASE }
      opt.on('-r', '--report', 'disp report') {|v| @report = true }
      opt.on('-m MATCH_RULE', '--match MATCH_RULE', 'match rule [line, tiddle, tweet]') {|v| @match_rule = v }
      opt.on('-c', '--comp', 'compression disp') {|v| @is_comp = true; @report = true }
      opt.parse!(arguments)
      
      @title_regexp = @title && Regexp.new(@title, @regexp_option)

      @content_regexps = []
      arguments.each do |keyword|
        @content_regexps << Regexp.new(keyword, @regexp_option)
      end

      unless validOption?
        puts opt.help
        exit
      end
    end

    def validOption?
      return false if !@file_name
      return @title || @content_regexps.size > 0
    end

    def match?(target)
      @content_regexps.each do |content_regexp|
        return false if content_regexp !~ target
      end
      return true
    end

    def match_line
      tiddles = Tiddle.parse_sort_modified(@file_name)

      match_lines = 0
      search_lines = 0
      match_tiddles = 0

      is_limit = false

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)
        is_match_tiddle = false
        line_no = 1

        tiddle.content.each_line do |line|
          if (match? line)
            match_lines += 1

            unless is_limit
              puts "#{tiddle.title}:#{line_no}:#{line}"

              if (@is_comp && match_lines > 5)
                is_limit = true
                print ".\n.\n"
              end
            end
              

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

      is_limit = false

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)

        match_tiddles += 1

        unless is_limit
          puts tiddle.title

          if (@is_comp && match_tiddles > 5)
            is_limit = true
            print ".\n.\n"
          end
        end
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

      is_limit = false

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)
        search_tiddles += 1

        if (match? tiddle.content)
          match_tiddles += 1

          unless is_limit
            puts "--- #{tiddle.title} --------------------"

            unless @is_comp
              puts tiddle.content
            else
              print tiddle.content.split(/\n/)[0..2].join("\n") + "\n.\n"
            end

            if (@is_comp && match_tiddles > 5)
              is_limit = true
              print ".\n.\n"
            end
          end
        end
      end

      if (@report)
        puts "------------------------------"
        puts "total tiddles : #{tiddles.size}"
        puts "search tiddles : #{search_tiddles}"
        puts "match tiddles : #{match_tiddles}"
      end
    end

    def match_tweet
      tiddles = Tiddle.parse_sort_modified(@file_name)

      search_tweets = 0
      match_tweets = 0

      is_limit = false

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)
        is_match_tiddle = false

        tweets = tiddle.content.split(/^----+\n/)
        search_tweets += tweets.size

        tweets.each do |tweet|
          if (match? tweet)
            match_tweets += 1
            unless is_limit
              unless is_match_tiddle
                puts "--- #{tiddle.title} --------------------"
                is_match_tiddle = true
              else
                puts "----\n"
              end

              unless @is_comp
                print tweet
              else
                print tweet.split(/\n/)[0..2].join("\n") + "\n.\n"
              end
              
              if (@is_comp && match_tweets > 5)
                is_limit = true
                print ".\n.\n"
              end
            end
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
      if (@content_regexps.size > 0) 
        case @match_rule
        when "line"
          match_line
        when "tiddle"
          match_tiddle
        when "tweet"
          match_tweet
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

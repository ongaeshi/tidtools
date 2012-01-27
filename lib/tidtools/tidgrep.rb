# -*- coding: utf-8 -*-
require 'tidtools/tiddle'
require 'tidtools/platform'
require 'kconv'

module Tidtools
  class Tidgrep
    # 圧縮表示時のパラメータ
    MATCH_LINE_COMP_NUM = 5

    MATCH_ONLY_TITLE_COMP_NUM = 5

    MATCH_TIDDLE_LINE_NUM = 3
    MATCH_TIDDLE_COMP_NUM = 5

    MATCH_TWEET_LINE_NUM = 3
    MATCH_TWEET_COMP_NUM = 5

    def initialize(stdout, file_names, file_no, title, regexp_option, report, match_rule, is_comp, keywords, kcode)
      @stdout = stdout
      @file_names = file_names
      @file_no = file_no
      @title = title
      @regexp_option = regexp_option
      @report = report
      @match_rule = match_rule
      @is_comp = is_comp
      @kcode = kcode

      @title_regexp = @title && Regexp.new(@title, @regexp_option)

      @content_regexps = []
      keywords.each do |keyword|
        @content_regexps << Regexp.new(kcode2utf(keyword), @regexp_option)
      end
    end

    def validOption?
      return false if @file_names.empty?
      return @title || @content_regexps.size > 0
    end

    def match?(target)
      @content_regexps.each do |content_regexp|
        return false if content_regexp !~ target
      end
      return true
    end

    def kcode2utf(str)
      if (@kcode != Kconv::UTF8)
        str.kconv(Kconv::UTF8, @kcode)
      else
        str
      end
    end

    def utf2kcode(str)
      if (@kcode != Kconv::UTF8)
        str.kconv(@kcode, Kconv::UTF8)
      else
        str
      end
    end

    def print(msg)
      @stdout.print utf2kcode(msg)
    end

    def puts(msg)
      @stdout.puts utf2kcode(msg)
    end

    def create_tiddles
      tiddles = []
      
      if (@file_no <= 0)
        @file_names.each do |file_name|
          tiddles.concat Tiddle.parse_sort_modified(file_name)
        end
      elsif (@file_no <= @file_names.size)
        tiddles.concat Tiddle.parse_sort_modified(@file_names[@file_no - 1])        
      end

      tiddles
    end
    private :create_tiddles

    def match_line
      tiddles = create_tiddles

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

              if (@is_comp && match_lines >= MATCH_LINE_COMP_NUM)
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
      tiddles = create_tiddles

      match_tiddles = 0

      is_limit = false

      tiddles.each do |tiddle|
        next if (@title && tiddle.title !~ @title_regexp)

        match_tiddles += 1

        unless is_limit
          puts tiddle.title

          if (@is_comp && match_tiddles >= MATCH_ONLY_TITLE_COMP_NUM)
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
      tiddles = create_tiddles

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
              tiddle_a = tiddle.content.split(/\n/)

              if (tiddle_a.size <= MATCH_TIDDLE_LINE_NUM)
                print tiddle.content
              else
                print tiddle_a[0..(MATCH_TIDDLE_LINE_NUM - 1)].join("\n") + "\n.\n"
              end
            end

            if (@is_comp && match_tiddles >= MATCH_TIDDLE_COMP_NUM)
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
      tiddles = create_tiddles

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
                tweet_a = tweet.split(/\n/)
                
                if (tweet_a.size <= MATCH_TWEET_LINE_NUM)
                  print tweet
                else
                  print tweet_a[0..(MATCH_TWEET_LINE_NUM - 1)].join("\n") + "\n.\n"
                end
              end
              
              if (@is_comp && match_tweets >= MATCH_TWEET_COMP_NUM)
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

    def execute
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
end

# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/01/27

require 'test_helper'
require 'tidtools/tiddler2texts'

class TestTiddler2texts < Test::Unit::TestCase
  include Tidtools

  def test_escape
    assert_equal "afile", Tiddler2texts.escape("afile")    
    assert_equal "／path／to／dir", Tiddler2texts.escape("/path/to/dir")
  end
end


